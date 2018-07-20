class MoveComponent < GKAgent3D
  include Map

  def init
    super
    self.delegate = self
  end

  def assign_properties(max_speed, maxAcceleration: max_acceleration, radius: radius, entityManager: entity_manager)
    @entity_manager = entity_manager
    self.maxSpeed = max_speed
    self.maxAcceleration = max_acceleration
    self.radius = radius
    self.mass = 0.01
  end

  def agentWillUpdate(agent)
    PositionUpdater.scn_vec_to_float(agent, toPosition: entity.componentForClass(VisualComponent).node.position)
  end

  def agentDidUpdate(agent)
    entity.componentForClass(VisualComponent).node.position = [agent.position.x, agent.position.y, agent.position.z]
  end

  def closest_move_component
    closest_component = nil
    closest_distance = 0

    enemy_move_components = @entity_manager.move_components
    enemy_move_components.each do |enemy_move_component|
      distance = distance_between_components(enemy_move_component, self)
      if closest_component.nil? || distance < closest_distance
        closest_component = enemy_move_component
        closest_distance = distance
      end
    end
    closest_component
  end

  def distance_between_components(a, b)
    a_x = a.entity.componentForClass(VisualComponent).node.position.x
    a_z = a.entity.componentForClass(VisualComponent).node.position.z

    b_x = b.entity.componentForClass(VisualComponent).node.position.x
    b_z = b.entity.componentForClass(VisualComponent).node.position.z
    Math.sqrt((a_x - b_x)**2 + (a_z - b_z)**2)
  end

  def distance_between_nodes(a, b)
    Math.sqrt((a.position.x - b.position.x)**2 +
              (a.position.y - b.position.y)**2 +
              (a.position.z - b.position.z)**2)
  end

  def updateWithDeltaTime(seconds)
    super
    @entity_manager.survivor.componentForClass(LocationComponent).node.position = @entity_manager.scene_view.pointOfView.position
    loc = @entity_manager.survivor.componentForClass(LocationComponent).node.position
    agent = @entity_manager.survivor.componentForClass(SurvivorComponent)
    PositionUpdater.scn_vec_to_float(agent, toPosition: loc)

    enemy_move_component = closest_move_component
    return if enemy_move_component.nil?
    allied_move_component = @entity_manager.move_components
    current_state = entity.componentForClass(VisualComponent).state_machine.currentState
    if current_state.is_a?(EnemyChaseState)
      self.behavior ||= MoveBehaviour.new.setupGoals(agent)#, avoid: enemy_move_component)
    elsif self.behavior.is_a?(MoveBehaviour) && current_state.is_a?(EnemyFleeState)
      self.behavior = EvadeBehaviour.new.setupGoals(agent)#, avoid: enemy_move_component)
    end

    if distance_between_nodes(entity.node.presentationNode, @entity_manager.scene_view.pointOfView) > spawn_radius + 5
      entity.componentForClass(VisualComponent).node.removeFromParentNode
      index = @entity_manager.entities.index(entity)
      @entity_manager.entities -= [entity]
      @entity_manager.ar_controller.mini_map_view.subviews[index + 1].removeFromSuperview
    end
  end
end