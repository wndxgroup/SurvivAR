class EnemyChaseState < EnemyState
  def assign_entity(entity)
    super
  end

  def isValidNextState(state_class)
    state_class == EnemyFleeState
  end

  def didEnterWithPreviousState(previous_state)
  end

  def updateWithDeltaTime(seconds)
  end
end