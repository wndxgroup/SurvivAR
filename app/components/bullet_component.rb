class BulletComponent < GKComponent
  attr_accessor :node

  def init
    super
    geometry = SCNSphere.sphereWithRadius(0.01)
    material = SCNMaterial.material
    material.diffuse.contents = NSColor.colorWithRed(0, green: 0, blue: 0, alpha: 1)
    material.doubleSided = false
    geometry.materials = [material]
    @node = SCNNode.nodeWithGeometry(geometry)
    self
  end

end