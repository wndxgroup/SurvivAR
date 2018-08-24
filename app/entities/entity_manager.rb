class EntityManager
  attr_accessor :entities, :survivor, :scene_view, :bullets

  def init(scene_view)
    @scene_view = scene_view
    @entities  = []
    @to_remove = []
    @bullets   = []
    @component_system = GKComponentSystem.alloc.initWithComponentClass(DemonAgent)
    self
  end

  def assign_survivor(survivor)
    @survivor = survivor
  end

  def add(entity, map_icon)
    @entities << [entity, map_icon]
    @component_system.addComponentWithEntity(entity)
  end

  def remove(entity)
    index = @entities.index{ |x| x[0] == entity }
    entity.node.removeFromParentNode
    @entities[index][1].removeFromSuperview
    @to_remove << entity
    @entities.delete_at(index)
  end

  def add_bullet(bullet)
    @bullets << bullet
    bullet.add_entity_manager(self)
  end

  def demons
    @entities.map { |entity| entity[0].componentForClass(DemonAgent) }
  end

  def updateWithDeltaTime(seconds)
    @survivor.updateWithDeltaTime(seconds)
    @component_system.updateWithDeltaTime(seconds)
    @bullets.each { |bullet| bullet.updateWithDeltaTime(seconds) } if @bullets.count > 0
    @to_remove.each { |current_remove| @component_system.removeComponentWithEntity(current_remove) }
    @to_remove = []
  end
end