class VisualComponent < GKComponent
  attr_accessor :node, :state_machine

  def init
    super
    target_geometry = SCNSphere.sphereWithRadius(1)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = UIColor.blackColor
    target_geometry.materials = [target_material]
    @node = SCNNode.nodeWithGeometry(target_geometry)
    particle_system = SCNParticleSystem.particleSystemNamed('fire.scnp', inDirectory: nil)
    @node.addParticleSystem(particle_system)

    chase = EnemyChaseState.new
    chase.assign_entity(entity)
    flee = EnemyFleeState.new
    flee.assign_entity(entity)
    @state_machine = GKStateMachine.alloc.initWithStates([chase, flee])
    @state_machine.enterState(EnemyChaseState)
    self
  end

  def updateWithDeltaTime(seconds)
    @state_machine.updateWithDeltaTime(seconds)
  end
end