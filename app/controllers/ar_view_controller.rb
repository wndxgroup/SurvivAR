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

    # @map_view = UIView.new
    # view.addSubview(@map_view)
    # @map_view.translatesAutoresizingMaskIntoConstraints = false
    # @map_view.widthAnchor.constraintEqualToConstant(70).active = true
    # @map_view.heightAnchor.constraintEqualToConstant(70).active = true
    # @map_view.rightAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.rightAnchor).active = true
    # @map_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true

    # map_icon = UIImage.imageNamed('map-button')
    # map_icon_view = UIImageView.alloc.initWithImage(map_icon)
    # map_icon_view.frame = [[0, 0], [70, 70]]
    # @map_view.addSubview(map_icon_view)
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
    # elsif event.touchesForView(@map_view)
    #   push_user_to_map
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

  # def session(_, didUpdateFrame: _)
  #   current_update_time = Time.now
  #   secs_since_last_frame = 0
  #   if @previous_update_time
  #     secs_since_last_frame = current_update_time - @previous_update_time
  #   end
  #
  #
  #
  #   @previous_update_time = current_update_time
  #   pos = @entity_manager.entities[0].componentForClass(VisualComponent).node.position
  #   puts "X: #{pos.x}  Z: #{pos.z}"
  # end

  def renderer(renderer, updateAtTime: time)
    @entity_manager.updateWithDeltaTime(time)
  end
end