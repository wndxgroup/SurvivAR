class Account < CDQManagedObject

  include SurvivalTime

  def start_survival_session
    loop do
      unless self.state?
        self.start_time = nil
        break
      end
      calculate_survival_time_increase(self)
      Dispatch::Queue.main.sync { cdq.save }
    end
  end

  def stop_survival_session
    self.state = false
    self.start_time = nil
    cdq.save
  end

end