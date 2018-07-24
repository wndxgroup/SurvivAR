class LocationComponent < GKComponent
  attr_accessor :node

  def init
    super
    target_geometry = SCNSphere.sphereWithRadius(0.1)
    @node = SCNNode.nodeWithGeometry(target_geometry)
    self
  end
end