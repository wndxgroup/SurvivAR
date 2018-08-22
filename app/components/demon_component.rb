class DemonComponent < GKComponent
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

    chase = DemonChaseState.new
    chase.assign_entity(entity)
    flee = DemonFleeState.new
    flee.assign_entity(entity)
    @state_machine = GKStateMachine.alloc.initWithStates([chase, flee])
    @state_machine.enterState(DemonChaseState)
    self
  end

  def updateWithDeltaTime(seconds)
    @state_machine.updateWithDeltaTime(seconds)
  end
end