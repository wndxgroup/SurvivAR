class AmmoComponent < GKComponent
  attr_accessor :node

  def init
    super
    geometry = SCNBox.boxWithWidth(1, height: 1, length: 1, chamferRadius: 0.2)
    material = SCNMaterial.material
    material.diffuse.contents = UIColor.alloc.initWithRed(1, green: 215.0/255, blue: 0, alpha: 1)
    geometry.materials = [material]
    @node = SCNNode.nodeWithGeometry(geometry)
    self
  end
end