module Rankings
  def determine_kills_rankings
    @most_kills  = []
    @player.accounts.each do |acct|
      acct.rounds.each do |round|
        @most_kills.each_with_index do |rd, index|
          if round.kills == rd.kills && is_faster(round, rd) || round.kills > rd.kills
            @most_kills.insert(index, round)
            break
          elsif index + 1 == @most_kills.count # at the last element in `@most_kills`
            @most_kills << round
            break
          end
        end
        @most_kills << round if @most_kills.empty?
      end
    end
  end

  def determine_life_rankings
    @longest_life = []
    @player.accounts.each do |acct|
      acct.rounds.each do |round|
        @longest_life.each_with_index do |rd, index|
          if round.survival_time > rd.survival_time || round.survival_time == rd.survival_time && round.kills > rd.kills
            @longest_life.insert(index, round)
            break
          elsif index + 1 == @longest_life.count # at the last element in `@longest_life`
            @longest_life << round
            break
          end
        end
        @longest_life << round if @longest_life.empty?
      end
    end
  end

  def is_faster(round, rd)
    a = round.survival_time.split(':')
    b = rd.survival_time.split(':')
    a[0] < b[0] || a[0] == b[0] && a[1] < b[1] || a[0] == b[0] && a[1] == b[1] && a[2] < b[2]
  end
end