class ARViewController < UIViewController
  attr_accessor :scene_view, :scene_config

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

    @scene = SCNScene.scene
    @entity_manager = EntityManager.alloc.init(@scene)
    @scene_view.scene = @scene
    add_enemies
    add_ui
  end

  def viewDidAppear(_)
    @scene_view.session.runWithConfiguration(@scene_config, options: ARSessionRunOptionResetTracking)
    add_enemies
  end

  def add_ui
    @menu_view = UIView.new
    view.addSubview(@menu_view)
    @menu_view.translatesAutoresizingMaskIntoConstraints = false
    @menu_view.widthAnchor.constraintEqualToConstant(70).active = true
    @menu_view.heightAnchor.constraintEqualToConstant(70).active = true
    @menu_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true

    menu_icon = UIImage.imageNamed('menu-button')
    menu_icon_view = UIImageView.alloc.initWithImage(menu_icon)
    menu_icon_view.frame = [[0 ,0], [70, 70]]
    @menu_view.addSubview(menu_icon_view)

    @map_view = UIView.new
    view.addSubview(@map_view)
    @map_view.translatesAutoresizingMaskIntoConstraints = false
    @map_view.widthAnchor.constraintEqualToConstant(70).active = true
    @map_view.heightAnchor.constraintEqualToConstant(70).active = true
    @map_view.rightAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.rightAnchor).active = true
    @map_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true

    map_icon = UIImage.imageNamed('map-button')
    map_icon_view = UIImageView.alloc.initWithImage(map_icon)
    map_icon_view.frame = [[0, 0], [70, 70]]
    @map_view.addSubview(map_icon_view)
  end

  def add_enemies
    enemy = Enemy.new
    node_index = enemy.components.index{ |comp| comp.is_a?(VisualComponent) }
    @entity_manager.add(enemy.components[node_index].node)
  end

  def session(_, didUpdateFrame: _)
    #player_dies if touching_enemy
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
    if event.touchesForView(@menu_view)
      push_user_to_menu
    elsif event.touchesForView(@map_view)
      push_user_to_map
    else
      shoot
    end
  end

  def push_user_to_menu
    pause_session
    parentViewController.set_controller(parentViewController.menu_controller, from: self)
  end

  def push_user_to_map
    pause_session
    unless parentViewController.map_view_controller
      parentViewController.start_map(self)
    else
      parentViewController.set_controller(parentViewController.map_view_controller, from: self)
    end
  end

  def pause_session
    @scene_view.pointOfView.childNodes.each {|node| node.removeFromParentNode}
    @scene.rootNode.childNodes.each {|node| node.removeFromParentNode}
    @scene_view.session.pause
  end

  def shoot
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