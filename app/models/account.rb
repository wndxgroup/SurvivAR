class Account < CDQManagedObject
  include SurvivalTime
  include Survival

  def start_survival_session
    play_wave_sound
    self.start_time = Time.now
    Dispatch::Queue.new('start survival session').async do
      loop do
        unless self.battling?
          self.start_time = nil
          break
        end
        calculate_survival_time_increase(self)
        Dispatch::Queue.main.sync { cdq.save }
      end
    end
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