class MoveBehaviour < GKBehavior
  def setupGoals(seek_agent, avoid: avoid_agents)
    setWeight(1, forGoal: GKGoal.goalToSeekAgent(seek_agent))
    setWeight(5, forGoal: GKGoal.goalToWander(1))
    setWeight(100, forGoal: GKGoal.goalToAvoidAgents(avoid_agents, maxPredictionTime: 30.0))
    self
  end
end