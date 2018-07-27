class MenuLayout < MotionKit::Layout
  def layout
    background_color UIColor.blackColor

    add UILabel, :username do
      text_alignment UITextAlignmentCenter
      font UIFont.systemFontOfSize(45)
      text_color UIColor.whiteColor
    end

    add UILabel, :stats do
      text_alignment UITextAlignmentCenter
      font UIFont.systemFontOfSize(24)
      text_color UIColor.whiteColor
    end

    add UIButton, :battleground_button do
      font UIFont.systemFontOfSize(24)
      background_color UIColor.redColor
      title_color UIColor.whiteColor
      title 'Battleground'
    end

    add UIButton, :leaderboard_button do
      font UIFont.systemFontOfSize(24)
      background_color UIColor.greenColor
      title_color UIColor.whiteColor
      title 'Leaderboards'
    end

    add UIButton, :accounts_button do
      font UIFont.systemFontOfSize(20)
      background_color UIColor.whiteColor
      title_color UIColor.blackColor
      title 'Accounts'
    end
  end

  def add_constraints
    constraints(:username) do
      top.equals(30)
      width(view).minus(30)
      left(view).plus(15)
    end

    constraints(:stats) do
      top.equals(:username, NSLayoutAttributeBottom).plus(20)
      width(:username)
      left(:username)
    end

    button_padding = 20

    constraints(:battleground_button) do
      top.equals(:stats, NSLayoutAttributeBottom).plus(button_padding + 20)
      left.equals(:stats, NSLayoutAttributeLeft)
      width.equals(:stats)
      height 80
    end

    constraints(:leaderboard_button) do
      top.equals(:battleground_button, NSLayoutAttributeBottom).plus(button_padding / 2)
      left.equals(:battleground_button)
      width.equals(:battleground_button)
      height.equals(:battleground_button)
    end

    constraints(:accounts_button) do
      top.equals(:leaderboard_button, NSLayoutAttributeBottom).plus(button_padding / 2)
      left.equals(:battleground_button)
      width.equals(:battleground_button)
      height.equals(:battleground_button)
    end
  end
end