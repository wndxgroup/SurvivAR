class VisualComponent < GKComponent
  attr_accessor :node

  def init
    super
    target_geometry = SCNSphere.sphereWithRadius(0.2)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = NSColor.colorWithRed(1, green: 0, blue: 0, alpha: 1)
    target_material.doubleSided = false
    target_geometry.materials = [target_material]
    @node = SCNNode.nodeWithGeometry(target_geometry)
    @node.position = SCNVector3Make(0, 0, -1.5)
    self
  end
end