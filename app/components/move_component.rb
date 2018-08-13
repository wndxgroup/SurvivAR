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
    self.mass = 10
  end

  def agentWillUpdate(agent)
    PositionUpdater.scn_vec_to_float(agent, toPosition: entity.componentForClass(VisualComponent).node.position)
  end

  def agentDidUpdate(agent)
    entity.componentForClass(VisualComponent).node.position = [agent.position.x, agent.position.y, agent.position.z]
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
    loc = @entity_manager.scene_view.pointOfView.position
    @entity_manager.survivor.componentForClass(LocationComponent).node.position = loc
    agent = @entity_manager.survivor.componentForClass(SurvivorComponent)
    PositionUpdater.scn_vec_to_float(agent, toPosition: loc)

    allied_move_component = @entity_manager.move_components
    current_state = entity.componentForClass(VisualComponent).state_machine.currentState
    if current_state.is_a?(EnemyChaseState)
      self.behavior ||= MoveBehaviour.new.setupGoals(agent, avoid: allied_move_component)
    elsif self.behavior.is_a?(MoveBehaviour) && current_state.is_a?(EnemyFleeState)
      self.behavior = EvadeBehaviour.new.setupGoals(agent, avoid_agents: allied_move_component)
    end

    if distance_between_nodes(entity.node.presentationNode, @entity_manager.scene_view.pointOfView) > spawn_radius + 5
      index = @entity_manager.entities.index(entity)
      if index
        entity.componentForClass(VisualComponent).node.removeFromParentNode
        @entity_manager.entities -= [entity]
        @entity_manager.battleground_controller.mini_map_view.subviews[index + 1].removeFromSuperview
      end
    end
  end
end