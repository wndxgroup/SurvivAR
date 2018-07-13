class MoveBehaviour < GKBehavior
  def setupGoals(target_speed, seek: seek_agent)#, avoid: avoid_agents)
    if target_speed > 0
      #setWeight(1.0, forGoal: GKGoal.goalToWander(100.0))
      #setWeight(0.1, forGoal: GKGoal.goalToReachTargetSpeed(target_speed))
      setWeight(1.0, forGoal: GKGoal.goalToSeekAgent(seek_agent))
      # setWeight(1.0, for: GKGoal.goalToAvoidAgents(avoid_agents, maxPredictionTime: 1.0))
    end

    self
  end
end