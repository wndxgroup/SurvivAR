class MenuController < UIViewController
  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @layout.get(:username).text = Player.first.username
  end
end