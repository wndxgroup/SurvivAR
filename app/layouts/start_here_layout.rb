class StartHereLayout < MotionKit::Layout
  def layout
    background_color UIColor.blackColor

    add UIView, :header do
      background_color UIColor.colorWithRed(1, green: 189.0/255, blue: 74.0/255, alpha: 1)
      add UILabel, :header_title do
        text 'Start a New Game'
        text_alignment UITextAlignmentCenter
        font UIFont.systemFontOfSize(24)
      end
    end

    add UIImageView, :logo do
      frame [[0, 10], [200, 200]]
      image UIImage.imageNamed('full-logo')
    end

    add UITextField, :username do
      background_color UIColor.whiteColor
      placeholder 'Enter a name'
      text_alignment UITextAlignmentCenter
      font UIFont.systemFontOfSize(20)
      text_color UIColor.blackColor
      spell_checking_type UITextSpellCheckingTypeNo
      autocorrection_type UITextAutocorrectionTypeNo
      become_first_responder
    end

    add UIButton, :start_button do
      title 'Begin'
      background_color UIColor.redColor
      title_color UIColor.blackColor
      font UIFont.systemFontOfSize(20)
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

    constraints(:logo) do
      top.equals(:header, NSLayoutAttributeBottom).plus(30)
      left.equals(view).plus(25)
      width.equals(view).minus(50)
      height :scale
    end

    constraints(:username) do
      top.equals(:logo, NSLayoutAttributeBottom).plus(30)
      left.equals(:logo, NSLayoutAttributeLeft)
      width.equals(:logo).minus(100)
      height 50
    end

    constraints(:start_button) do
      top.equals(:username)
      right.equals(:logo, NSLayoutAttributeRight)
      width 80
      height.equals(:username)
    end
  end
end