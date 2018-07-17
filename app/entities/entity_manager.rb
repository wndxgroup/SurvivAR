class EntityManager
  attr_accessor :entities, :scene, :survivor, :scene_view, :bullets

  def init(scene, scene_view)
    @scene = scene
    @scene_view = scene_view
    @entities = []
    @to_remove = []
    @bullets = []
    @component_systems = begin
      move_system = GKComponentSystem.alloc.initWithComponentClass(MoveComponent)
      [move_system]
    end
    @bullet_component_system = begin
       bullet_system = GKComponentSystem.alloc.initWithComponentClass(BulletAgent)
       [bullet_system]
    end
    self
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
    @bullet_component_system.each {|comp_system| comp_system.addComponentWithEntity(bullet)}
  end

  def move_components
    @entities.map { |entity| entity.componentForClass(MoveComponent) }
  end

  def updateWithDeltaTime(seconds)
    @survivor.updateWithDeltaTime(seconds)
    @component_systems.each { |comp_system| comp_system.updateWithDeltaTime(seconds) }
    if @bullets.count > 0
      @bullet_component_system.each { |comp_system| comp_system.updateWithDeltaTime(seconds)}
    end
    @to_remove.each do |current_remove|
      @component_systems.each do |comp_system|
        comp_system.removeComponentWithEntity(current_remove)
      end
    end
    @to_remove = []
  end
end