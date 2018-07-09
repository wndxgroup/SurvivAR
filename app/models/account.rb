class Account < CDQManagedObject

  include SurvivalTime

  def start_survival_session
    loop do
      unless self.state?
        self.start_time = nil
        break
      end
      calculate_survival_time_increase(self)
      Dispatch::Queue.main.sync do
        cdq.save
        if seconds_to_next_wave <= -20
          stop_survival_session
          puts 'died'
        end
      end
    end
  end

  def stop_survival_session
    self.state = false
    self.start_time = nil
    cdq.save
  end

end