class Account < CDQManagedObject
  include SurvivalTime

  def survival_session_queue
    @@survival_session_queue ||= Dispatch::Queue.new('com.wndx.SurvivAR.start-survival-session')
  end

  def start_survival_session
    self.start_time = Time.now
    cdq.save
    tick_survival_time
  end

  def tick_survival_time
    unless self.battling?
      self.start_time = nil
      Dispatch::Queue.main.sync { cdq.save }
      return
    end
    calculate_survival_time_increase(self)
    survival_session_queue.after(0.1) { self.tick_survival_time }
  end

  def stop_survival_session
    self.start_time = nil
    cdq.save
  end

  def sorted_rounds
    self.rounds.array.sort{ |a,b| a.completed_on <=> b.completed_on }
  end

  def most_kills_round
    kills = sorted_rounds.map { |round| round.kills }
    kills.index(kills.max)
  end
end