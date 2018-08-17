class AmmoComponent < GKComponent
  include Colors

  attr_accessor :node

  def init
    super
    geometry = SCNBox.boxWithWidth(1, height: 1, length: 1, chamferRadius: 0.2)
    material = SCNMaterial.material
    material.diffuse.contents = ammo_color
    geometry.materials = [material]
    @node = SCNNode.nodeWithGeometry(geometry)
    self
  end
end