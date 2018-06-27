class ARViewController < UIViewController
  def enemy_radius; 0.2; end

  def init
    super
  end

  def viewDidLoad
    super
    @scene_view = ARSCNView.alloc.init
    @scene_view.autoenablesDefaultLighting = true
    @scene_view.delegate = self
    @scene_config = ARWorldTrackingConfiguration.alloc.init
    @scene_config.worldAlignment = ARWorldAlignmentGravityAndHeading
    @scene_view.session.runWithConfiguration(@scene_config)
    @scene_view.session.delegate = self
    self.view = @scene_view
    add_enemy
  end

  def add_enemy
    @scene = SCNScene.scene
    target_geometry = SCNSphere.sphereWithRadius(enemy_radius)
    target_material = SCNMaterial.material
    target_material.diffuse.contents = NSColor.colorWithRed(1, green: 0, blue: 0, alpha: 1)
    target_material.doubleSided = false
    target_geometry.materials = [target_material]
    target = SCNNode.nodeWithGeometry(target_geometry)
    target.position = @target_pos = SCNVector3Make(0, 0, -1.5)
    @scene.rootNode.addChildNode(target)
    @scene_view.scene = @scene
  end

  def session(_, didUpdateFrame: _)
    player_dies if touching_enemy
  end

  def player_dies
    puts 'dead'
  end

  def touching_enemy
    player = @scene_view.pointOfView.position
    Math.sqrt((@target_pos.x - player.x)**2 +
                  (@target_pos.y - player.y)**2 +
                  (@target_pos.z - player.z)**2)  <= enemy_radius
  end

  def touchesEnded(_, withEvent: event)
    bullet_geometry = SCNSphere.sphereWithRadius(0.01)
    bullet_material = SCNMaterial.material
    bullet_material.diffuse.contents = NSColor.colorWithRed(0, green: 0, blue: 0, alpha: 1)
    bullet_material.doubleSided = false
    bullet_geometry.materials = [bullet_material]
    bullet = SCNNode.nodeWithGeometry(bullet_geometry)
    bullet.position = @scene_view.pointOfView.position
    @scene.rootNode.addChildNode(bullet)
  end
end