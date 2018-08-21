class BulletAgent < GKAgent3D

  def updateWithDeltaTime(seconds)
    super
    @node = entity.componentForClass(BulletComponent).node
    delete_entity if @node.presentationNode.position.y < -10
  end

  def delete_entity
    entity.entity_manager.bullets -= [entity]
    @node.removeFromParentNode
  end
end