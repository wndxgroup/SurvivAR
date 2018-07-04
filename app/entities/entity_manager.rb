class EntityManager
  attr_accessor :entities, :scene

  def init(scene)
    @scene = scene
    @entities = []
    self
  end

  def add(entity)
    @entities << entity
  end

  def remove(entity)
    @entities -= entity
  end
end