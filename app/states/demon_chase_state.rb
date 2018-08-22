class DemonChaseState < DemonState
  def assign_entity(entity)
    super
  end

  def isValidNextState(state_class)
    state_class == DemonFleeState
  end
end