class LeaderboardLayout < MotionKit::Layout
  def layout
    background_color UIColor.blackColor

    add UIButton, :most_kills do
      title 'Most Kills'
    end

    add UIButton, :longest_life do
      title 'Longest Life'
    end

    add UITableView, :table do end
  end

  def add_constraints
    button_margin = 20

    constraints(:most_kills) do
      top.equals(view).plus(button_margin)
      left.equals(view).plus(button_margin)
      width.equals('50%').of(view).minus(button_margin * 1.5)
    end

    constraints(:longest_life) do
      top.equals(view).plus(button_margin)
      left.equals(:most_kills, :right).plus(button_margin)
      width.equals('50%').of(view).minus(button_margin * 1.5)
    end

    constraints(:table) do
      top.equals(:most_kills, :bottom).plus(button_margin)
      left.equals(view)
      width.equals(view)
      bottom 0
    end
  end
end