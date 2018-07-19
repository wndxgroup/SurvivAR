class Bullet < GKEntity
  attr_accessor :position, :agent, :entity_manager

  def init
    super
    addComponent(BulletComponent.new)
    addComponent(@agent = BulletAgent.new)
    self
  end

  def set_firing_location(position)
    node = self.componentForClass(BulletComponent).node
    node.position = @position = position
    node
  end

  def set_trajectory(trajectory, entity_manager: entity_manager)
    @agent.set_trajectory(trajectory, entity_manager: entity_manager)
  end

end