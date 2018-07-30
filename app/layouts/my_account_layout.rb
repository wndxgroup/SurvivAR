class MyAccountLayout < MotionKit::Layout
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

          add UILabel, :quick_view_title do
            font UIFont.systemFontOfSize(24)
            text_color UIColor.grayColor
          end

          add UIView, :quick_view_container do
            background_color UIColor.whiteColor
            add UILabel, :quick_view_kills do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '💀'
            end
            add UILabel, :quick_view_time do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '🕒'
            end
          end

          add UILabel, :start_battleground do
            font UIFont.systemFontOfSize(24)
            text_alignment UITextAlignmentCenter
            background_color UIColor.whiteColor
          end

          add UIButton, :toggle_log do
            font UIFont.systemFontOfSize(24)
          end

          add UILabel, :delete_account do
            font UIFont.systemFontOfSize(24)
            text_alignment UITextAlignmentCenter
            background_color UIColor.redColor
            text_color UIColor.whiteColor
            text 'Delete Account'
          end

          add UILabel, :history_title do
            font UIFont.systemFontOfSize(24)
            text_color UIColor.grayColor
            text 'Completed Rounds'
          end

          add UITableView, :history_table do

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

    constraints(:quick_view_title) do
      top.equals(:username, :bottom).plus(20)
      width(:username).minus(30)
      left(:username).plus(15)
    end

    constraints(:quick_view_container) do
      top.equals(:quick_view_title, :bottom).plus(10)
      width.equals(:username)
      left.equals(:username)
      height 100
    end

    constraints(:quick_view_kills) do
      top.equals(:quick_view_container)
      bottom.equals(:quick_view_container)
      left.equals(:quick_view_container)
      width.equals('50%').of(:quick_view_container)
    end

    constraints(:quick_view_time) do
      top.equals(:quick_view_container)
      bottom.equals(:quick_view_container)
      left.equals(:quick_view_kills, :right)
      width.equals('50%').of(:quick_view_container)
    end

    button_padding = 10
    constraints(:start_battleground) do
      top.equals(:quick_view_container, :bottom).plus(50)
      left.equals(:quick_view_container)
      width.equals(:quick_view_container)
      height 60
    end

    constraints(:toggle_log) do
      top.equals(:start_battleground, :bottom).plus(button_padding)
      left.equals(:start_battleground)
      width.equals(:start_battleground)
      height.equals(:start_battleground)
    end

    constraints(:delete_account) do
      top.equals(:toggle_log, :bottom).plus(button_padding)
      left.equals(:toggle_log)
      width.equals(:toggle_log)
      height.equals(:start_battleground)
    end

    constraints(:history_title) do
      top.equals(:delete_account, :bottom).plus(50)
      width.equals(:quick_view_title)
      left.equals(:quick_view_title)
    end

    constraints(:history_table) do
      top.equals(:history_title, :bottom).plus(10)
      left.equals(view)
      width.equals(view)
      height.equals(view).minus(50)
      bottom 0
    end
  end
end