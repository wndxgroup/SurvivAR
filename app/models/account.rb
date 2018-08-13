class Account < CDQManagedObject
  include SurvivalTime

  def start_survival_session
    self.start_time = Time.now
    Dispatch::Queue.new('com.wndx.SurvivAR.start-survival-session').async do
      loop do
        unless self.battling?
          self.start_time = nil
          break
        end
        calculate_survival_time_increase(self)
      end
    end
    cdq.save
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