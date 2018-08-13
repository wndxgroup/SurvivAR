class BulletAgent < GKAgent3D

  def updateWithDeltaTime(seconds)
    super
    @node = entity.componentForClass(BulletComponent).node
    delete_entity if @node.presentationNode.position.y < -2
  end

  def delete_entity
    @node.removeFromParentNode
    entity.entity_manager.bullet_component_system[0].removeComponentWithEntity(entity)
    entity.entity_manager.bullets -= [entity]
  end
end