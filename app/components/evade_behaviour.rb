class EvadeBehaviour < GKBehavior
  def setupGoals(player, avoid_agents: avoid_agents)
    setWeight(1, forGoal: GKGoal.goalToFleeAgent(player))
    setWeight(100, forGoal: GKGoal.goalToAvoidAgents(avoid_agents, maxPredictionTime: 30.0))
    self
  end
end