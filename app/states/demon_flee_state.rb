class DemonFleeState < DemonState
  def assign_entity(entity)
    super
  end

  def isValidNextState(state_class)
    state_class == DemonChaseState
  end
end