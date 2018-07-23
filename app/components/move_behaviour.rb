class MoveBehaviour < GKBehavior
  def setupGoals(seek_agent, avoid: avoid_agents)
    setWeight(0.2, forGoal: GKGoal.goalToSeekAgent(seek_agent))
    setWeight(1.0, forGoal: GKGoal.goalToAvoidAgents(avoid_agents, maxPredictionTime: 30.0))
    #setWeight(1.0, forGoal: GKGoal.goalToSeparateFromAgents(avoid_agents, maxDistance: 1.0, maxAngle: 3))
    self
  end
end