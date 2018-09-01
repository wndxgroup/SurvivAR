class Demon < GKEntity
  include Map

  attr_accessor :node, :state_machine

  def init
    super
    chase = DemonChaseState.new
    chase.assign_entity(self)
    flee = DemonFleeState.new
    flee.assign_entity(self)
    @state_machine = GKStateMachine.alloc.initWithStates([chase, flee])
    @state_machine.enterState(DemonChaseState)
    self
  end

  def add_components(entity_manager)
    agent = DemonAgent.new
    agent.assign_properties(0.0000012, maxAcceleration: 5, radius: 1, entityManager: entity_manager)
    @entity_manager = entity_manager
    addComponent(agent)
  end

  def set_spawning_location(x=nil, z=nil)
    unless x && z
      x = rand * spawn_radius
      x = -x if rand < 0.5
      z = Math.sqrt(spawn_radius**2 - x**2)
      z = -z if rand < 0.5
      survivor_position = @entity_manager.survivor.node.position
      x += survivor_position.x
      z += survivor_position.z
    end

    target_geometry = SCNSphere.sphereWithRadius(1)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = UIColor.blackColor
    target_geometry.materials = [target_material]
    @node = SCNNode.nodeWithGeometry(target_geometry)
    @node.position = [x, 0, z]

    particle_system = SCNParticleSystem.particleSystemNamed('fire.scnp', inDirectory: nil)
    @node.addParticleSystem(particle_system)

    @node.physicsBody = SCNPhysicsBody.bodyWithType(SCNPhysicsBodyTypeDynamic, shape: nil)
    @node.physicsBody.categoryBitMask = 2
    @node.physicsBody.collisionBitMask = 1
    @node.physicsBody.contactTestBitMask = 1
    @node.physicsBody.affectedByGravity = false
    @node
  end
end