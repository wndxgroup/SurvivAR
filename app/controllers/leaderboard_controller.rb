class LeaderboardController < UIViewController
  def loadView
    self.title = 'Leaderboard'
    @layout = LeaderboardLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @table = @layout.get(:table)
    @player = Player.first
    @most_kills_button   = @layout.get(:most_kills)
    @longest_life_button = @layout.get(:longest_life)
    @filter = 'most kills'
  end

  def viewDidLoad
    @table.dataSource = @table.delegate = self
    @most_kills_button.addTarget(self, action: 'filter_by_kills', forControlEvents: UIControlEventTouchUpInside)
    @longest_life_button.addTarget(self, action: 'filter_by_survival_time', forControlEvents: UIControlEventTouchUpInside)
    filter_by_kills
  end

  def set_filter_buttons
    if @filter == 'most kills'
      @most_kills_button.backgroundColor = UIColor.colorWithRed(1.0, green: 0, blue: 0, alpha: 1)
      @longest_life_button.backgroundColor = UIColor.colorWithRed(0.5, green: 0, blue: 0, alpha: 1)
    else
      @most_kills_button.backgroundColor = UIColor.colorWithRed(0.5, green: 0, blue: 0, alpha: 1)
      @longest_life_button.backgroundColor = UIColor.colorWithRed(1.0, green: 0, blue: 0, alpha: 1)
    end
    @table.reloadData
  end

  def filter_by_kills
    @filter = 'most kills'
    determine_kills_rankings unless @most_kills
    set_filter_buttons
  end

  def filter_by_survival_time
    @filter = 'survival time'
    determine_life_rankings unless @longest_life
    set_filter_buttons
  end

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

  def tableView(_, numberOfRowsInSection: _)
    @player.accounts.map{|acct| acct.rounds.count}.inject(0){|sum, x| sum + x}
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELLID)
      cell
    end
    round = @filter == 'most kills' ? @most_kills[indexPath.row] : @longest_life[indexPath.row]
    text_label = "#{round.account.username}"
    if indexPath.row == 0
      text_label += ' 🥇'
    elsif indexPath.row == 1
      text_label += ' 🥈'
    elsif indexPath.row == 2
      text_label += ' 🥉'
    end
    cell.textLabel.text = text_label
    cell.detailTextLabel.text = "#{round.kills} kills in #{round.survival_time}"
    cell
  end
end