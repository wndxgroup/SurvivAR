class EvadeBehaviour < GKBehavior
  def setupGoals(player, avoid_agents: avoid_agents)
    setWeight(0.001, forGoal: GKGoal.goalToFleeAgent(player))
    setWeight(1.0, forGoal: GKGoal.goalToAvoidAgents(avoid_agents, maxPredictionTime: 30.0))
    self
  end
end