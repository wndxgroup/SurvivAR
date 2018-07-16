class ARViewController < UIViewController
  attr_accessor :scene_view, :scene_config

  def enemy_radius; 1.0; end

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
    @entity_manager = EntityManager.alloc.init(@scene, @scene_view)
    @scene_view.scene = @scene

    @survivor = Survivor.new
    node = @survivor.survivor_node
    @scene.rootNode.addChildNode(node)
    @entity_manager.assign_survivor(@survivor)

    add_ui
  end

  def viewDidAppear(_)
    @scene_view.session.runWithConfiguration(@scene_config, options: ARSessionRunOptionResetTracking)
    if @entity_manager.entities.count > 0
      display_enemies
    else
      spawn_enemy
    end
  end

  def add_ui
    @mini_map_view = MKMapView.alloc.init
    @mini_map_view.showsUserLocation = true
    @mini_map_view.rotateEnabled     = false
    @mini_map_view.scrollEnabled     = false
    @mini_map_view.showsCompass      = false
    @mini_map_view.zoomEnabled       = false
    @mini_map_view.delegate          = self

    view.addSubview(@mini_map_view)
    @mini_map_view.translatesAutoresizingMaskIntoConstraints = false
    @mini_map_view.widthAnchor.constraintEqualToConstant(120).active = true
    @mini_map_view.heightAnchor.constraintEqualToConstant(70).active = true
    @mini_map_view.leftAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.leftAnchor).active = true
    @mini_map_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true

    @menu_view = UIView.new
    view.addSubview(@menu_view)
    @menu_view.translatesAutoresizingMaskIntoConstraints = false
    @menu_view.widthAnchor.constraintEqualToConstant(70 + 120).active = true
    @menu_view.heightAnchor.constraintEqualToConstant(70).active = true
    @menu_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true

    menu_icon = UIImage.imageNamed('menu-button')
    menu_icon_view = UIImageView.alloc.initWithImage(menu_icon)
    menu_icon_view.frame = [[120 ,0], [70, 70]]
    @menu_view.addSubview(menu_icon_view)
  end

  def mapViewDidFinishLoadingMap(_)
    Dispatch::Queue.new('set_map_region_and_tracking_mode').async do
      while parentViewController.current_map_location.nil?; end
      span = MKCoordinateSpanMake(0.0125, 0.0125)
      region = MKCoordinateRegionMake(parentViewController.current_map_location.coordinate, span)
      @mini_map_view.setRegion(region, animated: false)
      @mini_map_view.setUserTrackingMode(MKUserTrackingModeFollowWithHeading, animated: false)
    end
  end

  def spawn_enemy
    enemy = Enemy.new
    enemy.add_components(@entity_manager)
    node = enemy.set_spawning_location
    @entity_manager.add(enemy)
    @scene.rootNode.addChildNode(node)
  end

  def display_enemies
    @entity_manager.entities.each { |entity| @scene.rootNode.addChildNode(entity)}
  end

  def session(_, didUpdateFrame: _)
    player_dies if touching_enemy
  end

  def player_dies
    player = Player.first
    current_player = player.accounts[player.current_account]
    current_player.alive = false
    current_player.start_time = nil
    cdq.save
    push_user_to_death_screen
  end

  def touching_enemy
    player = @scene_view.pointOfView.position
    @entity_manager.entities.any? do |entity|
      entity_position = entity.componentForClass(VisualComponent).node.position
      Math.sqrt((entity_position.x - player.x)**2 +
                (entity_position.y - player.y)**2 +
                (entity_position.z - player.z)**2)  <= enemy_radius

    end
  end

  def touchesEnded(_, withEvent: event)
    if event.touchesForView(@menu_view)
      push_user_to_menu
    else
      shoot
    end
  end

  def push_user_to_menu
    pause_session
    parentViewController.set_controller(parentViewController.menu_controller, from: self)
  end

  def push_user_to_death_screen
    pause_session
    parentViewController.set_controller(parentViewController.death_controller, from: self)
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

  def renderer(renderer, updateAtTime: time)
    @entity_manager.updateWithDeltaTime(time)
  end
end