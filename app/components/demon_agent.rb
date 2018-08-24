class DemonAgent < GKAgent3D
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
    PositionUpdater.scn_vec_to_float(agent, toPosition: entity.node.position)
  end

  def agentDidUpdate(agent)
    entity.node.position = [agent.position.x, agent.position.y, agent.position.z]
  end

  def distance_between_components(a, b)
    a_x = a.entity.node.position.x
    a_z = a.entity.node.position.z

    b_x = b.entity.node.position.x
    b_z = b.entity.node.position.z
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
    @entity_manager.survivor.node.position = loc
    agent = @entity_manager.survivor.componentForClass(SurvivorAgent)
    PositionUpdater.scn_vec_to_float(agent, toPosition: loc)

    allied_move_component = @entity_manager.move_components
    current_state = entity.state_machine.currentState
    if current_state.is_a?(DemonChaseState)
      self.behavior ||= MoveBehavior.new.setupGoals(agent, avoid: allied_move_component)
    elsif self.behavior.is_a?(MoveBehavior) && current_state.is_a?(DemonFleeState)
      self.behavior = EvadeBehavior.new.setupGoals(agent, avoid_agents: allied_move_component)
    end

    if distance_between_nodes(entity.node.presentationNode, @entity_manager.scene_view.pointOfView) > spawn_radius + 5
      @entity_manager.remove(entity)
    end
  end
end