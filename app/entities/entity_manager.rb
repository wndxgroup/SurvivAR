class EntityManager
  attr_accessor :entities, :scene

  def init(scene)
    @scene = scene
    @entites = []
    self
  end

  def add(entity)
    @entites << entity
    @scene.rootNode.addChildNode(entity)
  end

  def remove(entity)
    @entites -= entity
  end
end