class MoveComponent < GKAgent3D

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

  def updateWithDeltaTime(seconds)
    super
    @entity_manager.survivor.componentForClass(LocationComponent).node.position = @entity_manager.scene_view.pointOfView.position
    loc = @entity_manager.survivor.componentForClass(LocationComponent).node.position
    agent = @entity_manager.survivor.componentForClass(SurvivorComponent)
    PositionUpdater.scn_vec_to_float(agent, toPosition: loc)

    enemy_move_component = closest_move_component
    return if enemy_move_component.nil?
    allied_move_component = @entity_manager.move_components
    self.behavior = MoveBehaviour.new.setupGoals(self.maxSpeed, seek: agent)#, avoid: enemy_move_component)
  end
end