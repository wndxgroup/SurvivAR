class EntityManager
  attr_accessor :entities, :scene, :survivor, :scene_view, :bullets, :battleground_controller

  def init(scene, scene_view, battleground_controller)
    @battleground_controller = battleground_controller
    @scene = scene
    @scene_view = scene_view
    @entities  = []
    @to_remove = []
    @bullets   = []
    @component_systems = [GKComponentSystem.alloc.initWithComponentClass(MoveComponent)]
    @bullet_component_system = [GKComponentSystem.alloc.initWithComponentClass(BulletAgent)]
    self
  end

  def bullet_component_system
    @bullet_component_system
  end

  def assign_survivor(survivor)
    @survivor = survivor
  end

  def add(entity)
    @entities << entity
    @component_systems.each {|comp_system| comp_system.addComponentWithEntity(entity)}
  end

  def remove(entity)
    entity.componentForClass(VisualComponent).node.removeFromParentNode
    @entities -= entity
    @to_remove << entity
  end

  def add_bullet(bullet)
    @bullets << bullet
    bullet.add_entity_manager(self)
    @bullet_component_system.each {|comp_system| comp_system.addComponentWithEntity(bullet)}
  end

  def move_components
    @entities.map { |entity| entity.componentForClass(MoveComponent) }
  end

  def updateWithDeltaTime(seconds)
    entities.each { |entity| entity.componentForClass(VisualComponent).updateWithDeltaTime(seconds) }
    @survivor.updateWithDeltaTime(seconds)
    @component_systems.each { |comp_system| comp_system.updateWithDeltaTime(seconds) }
    # if @bullets.count > 0
    #   @bullet_component_system.each { |comp_system| comp_system.updateWithDeltaTime(seconds) }
    # end
    @to_remove.each do |current_remove|
      @component_systems.each do |comp_system|
        comp_system.removeComponentWithEntity(current_remove)
      end
    end
    @to_remove = []
  end
end