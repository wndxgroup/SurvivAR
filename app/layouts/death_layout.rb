class DeathLayout < MotionKit::Layout
  def layout
    background_color UIColor.blackColor

    add UILabel, :name_field do
      text_alignment UITextAlignmentCenter
      font UIFont.systemFontOfSize(30)
      text_color UIColor.whiteColor
    end

    add UILabel, :duration do
      text_alignment UITextAlignmentCenter
      font UIFont.systemFontOfSize(45)
      background_color UIColor.redColor
      text_color UIColor.blackColor
    end

    add UILabel, :inspiration do
      text_alignment UITextAlignmentCenter
      text 'Better luck next time'
      font UIFont.systemFontOfSize(25)
      text_color UIColor.whiteColor
    end

    add UIImageView, :logo do
      frame [[0, 10], [200, 200]]
      image UIImage.imageNamed('full-logo')
    end

    add UIButton, :accounts_button do
      font UIFont.systemFontOfSize(20)
      background_color UIColor.whiteColor
      title 'Accounts'
      title_color UIColor.blackColor
    end
  end

  def add_constraints
    constraints(:name_field) do
      top.equals(40)
      width.equals(view)
    end

    constraints(:duration) do
      top.equals(:name_field, NSLayoutAttributeBottom).plus(15)
      width.equals(view)
    end

    constraints(:inspiration) do
      top.equals(:duration, NSLayoutAttributeBottom).plus(15)
      width.equals(view)
    end

    constraints(:logo) do
      top.equals(:inspiration, NSLayoutAttributeBottom).plus(70)
      left.equals(view).plus(25)
      width.equals(view).minus(50)
      height :scale
    end

    constraints(:accounts_button) do
      top.equals(:logo, NSLayoutAttributeBottom).plus(40)
      width 200
      height 50
      center_x :logo
    end
  end
end