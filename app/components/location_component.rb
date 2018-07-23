class LocationComponent < GKComponent
  attr_accessor :node, :position

  def init
    super
    target_geometry = SCNSphere.sphereWithRadius(0.1)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = UIColor.clearColor
    target_geometry.materials = [target_material]
    @node = SCNNode.nodeWithGeometry(target_geometry)
    @node.position = [0, 0, -25]
    self
  end
end