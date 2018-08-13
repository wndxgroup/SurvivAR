class DeathLayout < MotionKit::Layout
  def layout
    root :root_view do
      add UIScrollView, :scroll_view do
        add UIView, :content_view do
          background_color UIColor.blackColor

          add UILabel, :round_stats_title do
            text 'Round Stats'
            font UIFont.systemFontOfSize(24)
            text_color UIColor.grayColor
          end

          add UIView, :round_stats_container do
            background_color UIColor.whiteColor
            add UILabel, :round_stats_kills do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '💥'
            end
            add UILabel, :round_stats_time do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '🕒'
            end
          end

          add UILabel, :round_ranking_title do
            text 'Round Ranking'
            font UIFont.systemFontOfSize(24)
            text_color UIColor.grayColor
          end

          add UIView, :round_ranking_container do
            background_color UIColor.whiteColor
            add UILabel, :round_ranking_kills do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '💥'
            end
            add UILabel, :round_ranking_time do
              font UIFont.systemFontOfSize(24)
              text_alignment UITextAlignmentCenter
              numberOfLines 3
              text '🕒'
            end
          end

          add UIButton, :replay do
            setImage UIImage.imageNamed('replay'), forState: UIControlStateNormal
          end

          add UIImageView, :logo do
            image UIImage.imageNamed('full-logo')
          end

          add UIButton, :new_round do
            title 'New Round'
            background_color UIColor.grayColor
            font UIFont.systemFontOfSize(24)
          end

          add UIButton, :leaderboard do
            title 'Leaderboard'
            background_color UIColor.whiteColor
            font UIFont.systemFontOfSize(24)
          end

          add UIButton, :my_account do
            title 'My Account'
            background_color UIColor.orangeColor
            font UIFont.systemFontOfSize(24)
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

    constraints(:round_stats_title) do
      top.equals(:content_view).plus(30)
      width.equals(view).minus(60)
      left 30
    end

    constraints(:round_stats_container) do
      top.equals(:round_stats_title, :bottom).plus(10)
      width.equals(view).minus(30)
      left 15
      height 100
    end

    constraints(:round_stats_kills) do
      top :round_stats_container
      left :round_stats_container
      width.equals('50%').of(:round_stats_container)
      bottom :round_stats_container
    end

    constraints(:round_stats_time) do
      top :round_stats_container
      left.equals(:round_stats_kills, :right)
      width :round_stats_kills
      bottom :round_stats_container
    end

    constraints(:round_ranking_title) do
      top.equals(:round_stats_container, :bottom).plus(30)
      left :round_stats_title
      width :round_stats_title
    end

    constraints(:round_ranking_container) do
      top.equals(:round_ranking_title, :bottom).plus(10)
      width :round_stats_container
      left :round_stats_container
      height :round_stats_container
    end

    constraints(:round_ranking_kills) do
      top :round_ranking_container
      left :round_ranking_container
      width.equals('50%').of(:round_ranking_container)
      bottom :round_ranking_container
    end

    constraints(:round_ranking_time) do
      top :round_ranking_container
      left.equals(:round_ranking_kills, :right)
      width :round_ranking_kills
      bottom :round_ranking_container
    end

    constraints(:replay) do
      top.equals(:round_ranking_container, :bottom).plus(30)
      width 100
      height 100
      center_x view
    end

    constraints(:logo) do
      top.equals(:replay, :bottom).plus(30)
      left :round_ranking_container
      width :round_ranking_container
      height.equals(:round_ranking_container, :width).divided_by(378.0).times(123)
    end

    button_padding = 10
    constraints(:new_round) do
      top.equals(:logo, :bottom).plus(50)
      left :round_ranking_container
      width :round_ranking_container
      height 60
    end

    constraints(:leaderboard) do
      top.equals(:new_round, :bottom).plus(button_padding)
      left :new_round
      width :new_round
      height :new_round
    end

    constraints(:my_account) do
      top.equals(:leaderboard, :bottom).plus(button_padding)
      left :leaderboard
      width :leaderboard
      height :leaderboard
      bottom -25
    end
  end
end