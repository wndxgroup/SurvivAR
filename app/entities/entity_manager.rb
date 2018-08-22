class EntityManager
  attr_accessor :entities, :scene, :survivor, :scene_view, :bullets, :battleground_controller

  def init(scene, scene_view, battleground_controller)
    @battleground_controller = battleground_controller
    @scene = scene
    @scene_view = scene_view
    @entities  = []
    @to_remove = []
    @bullets   = []
    @component_systems = [GKComponentSystem.alloc.initWithComponentClass(DemonAgent)]
    @bullet_component_system = [GKComponentSystem.alloc.initWithComponentClass(BulletAgent)]
    self
  end

  def bullet_component_system
    @bullet_component_system
  end

  def assign_survivor(survivor)
    @survivor = survivor
  end

  def add(entity, map_icon)
    @entities << [entity, map_icon]
    @component_systems.each {|comp_system| comp_system.addComponentWithEntity(entity)}
  end

  def remove(entity)
    index = @entities.index{ |x| x[0] == entity }
    entity.componentForClass(DemonComponent).node.removeFromParentNode
    @entities[index][1].removeFromSuperview
    @to_remove << entity
    @entities.delete_at(index)
  end

  def add_bullet(bullet)
    @bullets << bullet
    bullet.add_entity_manager(self)
    @bullet_component_system.each {|comp_system| comp_system.addComponentWithEntity(bullet)}
  end

  def move_components
    @entities.map { |entity| entity[0].componentForClass(DemonAgent) }
  end

  def updateWithDeltaTime(seconds)
    entities.each { |entity| entity[0].componentForClass(DemonComponent).updateWithDeltaTime(seconds) }
    @survivor.updateWithDeltaTime(seconds)
    @component_systems.each { |comp_system| comp_system.updateWithDeltaTime(seconds) }
    if @bullets.count > 0
      @bullet_component_system.each { |comp_system| comp_system.updateWithDeltaTime(seconds) }
    end
    @to_remove.each do |current_remove|
      @component_systems.each do |comp_system|
        comp_system.removeComponentWithEntity(current_remove)
      end
    end
    @to_remove = []
  end
end