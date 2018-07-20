class MoveBehaviour < GKBehavior
  def setupGoals(seek_agent)#, avoid: avoid_agents)
      setWeight(1.0, forGoal: GKGoal.goalToSeekAgent(seek_agent))
      # setWeight(1.0, for: GKGoal.goalToAvoidAgents(avoid_agents, maxPredictionTime: 1.0))
    self
  end
end