class BulletAgent < GKAgent3D
  attr_accessor :new_position

  def enemy_radius; 1.0; end

  def init
    super
    @trajectory = nil
    @entity_manager = nil
    self
  end

  def updateWithDeltaTime(seconds)
    super
    if @trajectory && @entity_manager
      current_position = entity.componentForClass(BulletComponent).node.position
      @new_position = SCNVector3Make(current_position.x + @trajectory['x'],
                                     current_position.y + @trajectory['y'],
                                     current_position.z + @trajectory['z'])
      entity.componentForClass(BulletComponent).node.position = @new_position
      delete_bullet if hit_enemy || out_of_bounds
    end
  end

  def delete_bullet
    puts 'deleting bullet'
    entity.dealloc
  end

  def hit_enemy
    @entity_manager.entities.any? do |entity|
      entity_position = entity.componentForClass(VisualComponent).node.position
      Math.sqrt((entity_position.x - @new_position.x)**2 +
                (entity_position.y - @new_position.y)**2 +
                (entity_position.z - @new_position.z)**2)  <= enemy_radius
    end
  end

  def out_of_bounds
    false # To be implemented
  end

  def set_trajectory(trajectory, entity_manager: entity_manager)
    @trajectory = trajectory
    @entity_manager = entity_manager
  end
end