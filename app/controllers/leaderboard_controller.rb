class LeaderboardController < UIViewController
  include Rankings, Colors

  def init
    super
    self.title = 'Leaderboard'
    self
  end

  def loadView
    @layout = LeaderboardLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @player = Player.first

    @table               = @layout.get(:table)
    @most_kills_button   = @layout.get(:most_kills)
    @longest_life_button = @layout.get(:longest_life)

    @table.dataSource = @table.delegate = self
    @most_kills_button  .addTarget(self, action: 'filter_by_kills',         forControlEvents: UIControlEventTouchUpInside)
    @longest_life_button.addTarget(self, action: 'filter_by_survival_time', forControlEvents: UIControlEventTouchUpInside)
  end

  def viewWillAppear(animated)
    super
    filter_by_kills
  end

  def set_filter_buttons
    if @filter == 'most kills'
      @most_kills_button  .backgroundColor = on_color
      @longest_life_button.backgroundColor = off_color
    else
      @most_kills_button  .backgroundColor = off_color
      @longest_life_button.backgroundColor = on_color
    end
    @table.reloadData
  end

  def filter_by_kills
    @filter = 'most kills'
    determine_kills_rankings
    set_filter_buttons
  end

  def filter_by_survival_time
    @filter = 'survival time'
    determine_life_rankings
    set_filter_buttons
  end

  def tableView(_, numberOfRowsInSection: _)
    @player.accounts.map {|acct| acct.rounds.count}.inject(0) {|sum, x| sum + x}
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier: CELLID)
    end
    round = @filter == 'most kills' ? @most_kills[indexPath.row] : @longest_life[indexPath.row]
    place_label = begin
      case indexPath.row
      when 0
        '🥇'
      when 1
        '🥈'
      when 2
        '🥉'
      else
        "##{indexPath.row + 1}:"
      end
    end
    cell.textLabel.text = place_label + " #{round.account.username}"
    cell.detailTextLabel.text = begin
      if @filter == 'most kills'
        "#{round.kills} kills in #{round.survival_time}"
      else
        "#{round.survival_time} with #{round.kills} kills"
      end
    end
    cell
  end
end