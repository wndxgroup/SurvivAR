class Bullet < GKEntity
  attr_accessor :position

  def init
    super
    addComponent(BulletComponent.new)
    addComponent(BulletAgent.new)
    self
  end

  def set_firing_location(position)
    node = self.componentForClass(BulletComponent).node
    node.position = @position = position
    node
  end
end