class AccountsLayout < MotionKit::Layout
  def layout
    add UIView, :header do
      background_color UIColor.colorWithRed(1, green: 189.0/255, blue: 74.0/255, alpha: 1)
      add UILabel, :header_title do
        text 'Accounts'
        text_alignment UITextAlignmentCenter
        font UIFont.systemFontOfSize(24)
      end
    end
  end

  def add_constraints
    constraints(:header) do
      top_left x: 0, y: 0
      width.equals(view)
      height 70
    end

    constraints(:header_title) do
      top_left x: 0, y: 0
      width.equals(:header)
      height.equals(:header)
    end
  end
end