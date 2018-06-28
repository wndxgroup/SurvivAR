class MenuLayout < MotionKit::Layout
  def layout
    background_color UIColor.blackColor

    add UIView, :header do
      background_color UIColor.colorWithRed(1, green: 189.0/255, blue: 74.0/255, alpha: 1)
      add UILabel, :header_title do
        text 'Menu'
        text_alignment UITextAlignmentCenter
        font UIFont.systemFontOfSize(24)
      end
    end

    add UILabel, :username do
      text_alignment UITextAlignmentCenter
      font UIFont.systemFontOfSize(45)
      text_color UIColor.whiteColor
    end

    add UILabel, :survival_time do
      text_alignment UITextAlignmentCenter
      font UIFont.systemFontOfSize(24)
      text_color UIColor.whiteColor
    end

    add UIButton, :map_button do
      font UIFont.systemFontOfSize(24)
      background_color UIColor.greenColor
      title_color UIColor.whiteColor
      title 'Map'
    end

    add UIButton, :vision_button do
      font UIFont.systemFontOfSize(24)
      background_color UIColor.blueColor
      title_color UIColor.whiteColor
      title 'Vision'
    end

    add UIButton, :settings_button do
      font UIFont.systemFontOfSize(24)
      background_color UIColor.whiteColor
      title 'Settings'
      title_color UIColor.blackColor
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

    constraints(:username) do
      top.equals(:header, NSLayoutAttributeBottom).plus(30)
      width(view).minus(30)
      left(view).plus(15)
    end

    constraints(:survival_time) do
      top.equals(:username, NSLayoutAttributeBottom).plus(20)
      width(:username)
      left(:username)
    end

    button_vertical_padding = 20

    constraints(:map_button) do
      top.equals(:survival_time, NSLayoutAttributeBottom).plus(button_vertical_padding + 20)
      left.equals(:survival_time, NSLayoutAttributeLeft)
      width.equals(:survival_time)
      height 80
    end

    constraints(:vision_button) do
      top.equals(:map_button, NSLayoutAttributeBottom).plus(button_vertical_padding)
      left.equals(:map_button)
      width.equals(:map_button)
      height.equals(:map_button)
    end

    constraints(:settings_button) do
      top.equals(:vision_button, NSLayoutAttributeBottom).plus(button_vertical_padding)
      left.equals(:map_button)
      width.equals(:map_button)
      height.equals(:map_button)
    end
  end
end