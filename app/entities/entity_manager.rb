class EntityManager
  attr_accessor :entities, :scene, :survivor

  def init(scene)
    @scene = scene
    @entities = []
    @to_remove = []
    @component_systems = begin
      move_system = GKComponentSystem.alloc.initWithComponentClass(MoveComponent)
      [move_system]
    end
    self
  end

  def assign_survivor(survivor)
    @survivor = survivor
  end

  def add(entity)
    @entities << entity

    # node = entity.componentForClass(VisualComponent).node
    # @scene.rootNode.addChildNode(node)

    @component_systems.each {|comp_system| comp_system.addComponentWithEntity(entity)}
  end

  def remove(entity)
    entity.componentForClass(VisualComponent).node.removeFromParentNode
    @entities -= entity
    @to_remove << entity
  end

  def move_components
    @entities.map { |entity| entity.componentForClass(MoveComponent) }
  end

  def updateWithDeltaTime(seconds)
    # unless @entities[0].nil?
    #   puts @entities[0].componentForClass(VisualComponent).node.position.x
    # end
    @survivor.updateWithDeltaTime(seconds)
    @component_systems.each { |comp_system| comp_system.updateWithDeltaTime(seconds) }
    @to_remove.each do |current_remove|
      @component_systems.each do |comp_system|
        comp_system.removeComponentWithEntity(current_remove)
      end
    end
    @to_remove = []
  end

  def spawn_enemies

  end
end