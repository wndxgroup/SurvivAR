class MenuController < UIViewController
  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    username = Player.first.accounts[Player.first.current_account].username
    @layout.get(:username).text = username
  end
end