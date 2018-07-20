class EvadeBehaviour < GKBehavior
  def setupGoals(player)
    setWeight(1.0, forGoal: GKGoal.goalToFleeAgent(player))
  end
end