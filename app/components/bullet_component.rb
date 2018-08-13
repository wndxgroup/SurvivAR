class BulletComponent < GKComponent
  attr_accessor :node

  def init
    super
    geometry = SCNSphere.sphereWithRadius(0.1)
    material = SCNMaterial.material
    material.diffuse.contents = UIColor.whiteColor
    geometry.materials = [material]
    @node = SCNNode.nodeWithGeometry(geometry)
    self
  end
end