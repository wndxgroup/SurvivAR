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
            text 'Overall Stats'
            font UIFont.systemFontOfSize(24)
            text_color UIColor.grayColor
          end

          add UIView, :quick_view_container do
            background_color UIColor.whiteColor
            add UILabel, :quick_view_kills do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '💥'
            end
            add UILabel, :quick_view_time do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '🕒'
            end
            add UILabel, :quick_view_rounds do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '💀'
            end
          end

          add UIButton, :start_battleground do
            font UIFont.systemFontOfSize(24)
            background_color UIColor.grayColor
          end

          add UIButton, :toggle_log do
            font UIFont.systemFontOfSize(24)
          end

          add UIButton, :delete_account do
            title 'Delete Account'
            background_color UIColor.redColor
            font UIFont.systemFontOfSize(24)
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
      width :root_view
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
      width :username
      left :username
      height 100
    end

    constraints(:quick_view_kills) do
      top :quick_view_container
      bottom :quick_view_container
      left :quick_view_container
      width.equals('25%').of(:quick_view_container)
    end

    constraints(:quick_view_time) do
      top :quick_view_container
      bottom :quick_view_container
      left.equals(:quick_view_kills, :right)
      width.equals('50%').of(:quick_view_container)
    end

    constraints(:quick_view_rounds) do
      top :quick_view_container
      bottom :quick_view_container
      left.equals(:quick_view_time, :right)
      width.equals('25%').of(:quick_view_container)
    end

    button_padding = 10
    constraints(:start_battleground) do
      top.equals(:quick_view_container, :bottom).plus(50)
      left :quick_view_container
      width :quick_view_container
      height 60
    end

    constraints(:toggle_log) do
      top.equals(:start_battleground, :bottom).plus(button_padding)
      left :start_battleground
      width :start_battleground
      height :start_battleground
    end

    constraints(:delete_account) do
      top.equals(:toggle_log, :bottom).plus(button_padding)
      left :toggle_log
      width :toggle_log
      height :start_battleground
    end

    constraints(:history_title) do
      top.equals(:delete_account, :bottom).plus(50)
      width :quick_view_title
      left :quick_view_title
    end

    constraints(:history_table) do
      top.equals(:history_title, :bottom).plus(10)
      left view
      width view
      height.equals(view).minus(50)
      bottom 0
    end
  end
end