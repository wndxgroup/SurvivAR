class Bullet < GKEntity
  attr_accessor :entity_manager, :node

  def init
    super
    addComponent(@agent = BulletAgent.new)
    self
  end

  def add_entity_manager(entity_manager)
    @entity_manager = entity_manager
  end

  def set_firing_location(position)
    @node = @agent.node
    @node.position = position
    @node
  end
end