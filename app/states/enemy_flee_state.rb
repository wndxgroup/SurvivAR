class EnemyFleeState < EnemyState
  def assign_entity(entity)
    super
  end

  def isValidNextState(state_class)
    state_class == EnemyChaseState
  end

  def didEnterWithPreviousState(previous_state)
  end

  def updateWithDeltaTime(seconds)
  end
end