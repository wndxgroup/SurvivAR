module Colors
  def orange
    @orange ||= UIColor.alloc.initWithRed(1.0, green: 189.0/255, blue: 74.0/255, alpha: 1.0)
  end

  def ammo_color
    @ammo_color ||= UIColor.alloc.initWithRed(68.0/255, green: 217.0/255, blue: 230.0/255, alpha: 1)
  end

  def on_color
    @on_color ||= UIColor.colorWithRed(1.0, green: 0, blue: 0, alpha: 1)
  end

  def off_color
    @off_color ||= UIColor.colorWithRed(0.5, green: 0, blue: 0, alpha: 1)
  end
end