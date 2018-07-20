class EnemyState < GKState
  attr_accessor :entity

  def assign_entity(entity)
    @entity = entity
  end
end