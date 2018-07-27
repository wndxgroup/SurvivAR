class MenuLayout < MotionKit::Layout
  def layout
    root :root_view do
      add UIScrollView, :scroll_view do
        add UIView, :content_view do
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
            background_color UIColor.grayColor
            add UITextView, :battleground_text do
              setUserInteractionEnabled false
              text_alignment UITextAlignmentCenter
              font UIFont.systemFontOfSize(24)
              text 'Battleground'
              background_color UIColor.clearColor
            end
            add UIImageView, :battleground_image do
              image UIImage.imageNamed('battlegrounds')
            end
          end

          add UIButton, :leaderboard_button do
            background_color UIColor.whiteColor
            add UITextView, :leaderboard_text do
              setUserInteractionEnabled false
              text_alignment UITextAlignmentCenter
              font UIFont.systemFontOfSize(24)
              text 'Leaderboards'
              background_color UIColor.clearColor
            end
            add UIImageView, :leaderboard_image do
              image UIImage.imageNamed('leaderboards')
            end
          end

          add UIButton, :accounts_button do
            background_color UIColor.orangeColor
            add UITextView, :accounts_text do
              setUserInteractionEnabled false
              text_alignment UITextAlignmentCenter
              font UIFont.systemFontOfSize(24)
              text 'Accounts'
              background_color UIColor.clearColor
            end
            add UIImageView, :accounts_image do
              image UIImage.imageNamed('accounts')
            end
          end
        end
      end
    end
  end

  def add_constraints
    constraints(:scroll_view) do
      top_left x: 0, y: 0
      bottom_right x: 0, y: 0
    end

    constraints(:content_view) do
      top_left x: 0, y: 0
      bottom_right x: 0, y: 0
      width.equals(:root_view)
      height.equals(:root_view).priority(:low)
    end

    constraints(:username) do
      top 30
      width(view).minus(30)
      left 15
    end

    constraints(:stats) do
      top.equals(:username, :bottom).plus(20)
      width(:username)
      left(:username)
    end

    button_padding = 20

    constraints(:battleground_button) do
      top.equals(:stats, :bottom).plus(button_padding + 20)
      left.equals(:stats, :left)
      width.equals(:stats)
      height.equals(:battleground_button, :width).plus(button_padding)
    end

    constraints(:battleground_text) do
      top.equals(:battleground_button).plus(5)
      left.equals(:battleground_button)
      width.equals(:battleground_button)
      height 40
    end

    constraints(:battleground_image) do
      top.equals(:battleground_text, :bottom).plus(5)
      left.equals(:battleground_button).plus(button_padding)
      width.equals(:battleground_button).minus(button_padding * 2)
      height.equals(:battleground_image, :width)
    end

    constraints(:leaderboard_button) do
      top.equals(:battleground_button, :bottom).plus(button_padding / 2)
      left.equals(:battleground_button)
      width.equals(:battleground_button)
      height.equals(:battleground_button)
    end

    constraints(:leaderboard_text) do
      top.equals(:leaderboard_button).plus(5)
      left.equals(:leaderboard_button)
      width.equals(:leaderboard_button)
      height 40
    end

    constraints(:leaderboard_image) do
      top.equals(:leaderboard_text, :bottom).plus(5)
      left.equals(:leaderboard_button).plus(button_padding)
      width.equals(:leaderboard_button).minus(button_padding * 2)
      height.equals(:leaderboard_image, :width)
    end

    constraints(:accounts_button) do
      top.equals(:leaderboard_button, :bottom).plus(button_padding / 2)
      left.equals(:battleground_button)
      width.equals(:battleground_button)
      height.equals(:battleground_button)
      bottom -20
    end

    constraints(:accounts_text) do
      top.equals(:accounts_button).plus(5)
      left.equals(:accounts_button)
      width.equals(:accounts_button)
      height 40
    end

    constraints(:accounts_image) do
      top.equals(:accounts_text, :bottom).plus(5)
      left.equals(:accounts_button).plus(button_padding)
      width.equals(:accounts_button).minus(button_padding * 2)
      height.equals(:accounts_image, :width)
    end
  end
end