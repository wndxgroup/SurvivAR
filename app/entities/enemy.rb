class Enemy < GKEntity
  def init
    super
    addComponent(VisualComponent.new)
    self
  end
end