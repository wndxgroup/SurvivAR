class ARViewController < UIViewController
  attr_accessor :scene_view, :scene_config

  def enemy_radius; 1.0; end
  def map_diameter; 120; end
  def map_icon_diameter; 10; end

  def init
    super
    @enemy_map_icons = []
    self
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
    @bullets = []
    @scene_view.session.runWithConfiguration(@scene_config, options: ARSessionRunOptionResetTracking)
    @currently_killing_player = false
    if @entity_manager.entities.count > 0
      display_enemies
    else
      spawn_enemy
    end
  end

  def add_ui
    @mini_map_view = UIView.new
    @mini_map_view.backgroundColor = UIColor.alloc.initWithWhite(0, alpha: 0.5)
    @mini_map_view.layer.cornerRadius = map_diameter / 2
    @mini_map_view.layer.masksToBounds = true
    view.addSubview(@mini_map_view)
    @mini_map_view.translatesAutoresizingMaskIntoConstraints = false
    @mini_map_view.widthAnchor.constraintEqualToConstant(map_diameter).active = true
    @mini_map_view.heightAnchor.constraintEqualToConstant(map_diameter).active = true
    @mini_map_view.leftAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.leftAnchor).active = true
    @mini_map_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true


    player_icon =  UIView.new
    player_icon.frame = [[map_diameter / 2 - map_icon_diameter / 2, map_diameter / 2 - map_icon_diameter / 2],
                         [map_icon_diameter, map_icon_diameter]]
    player_icon.backgroundColor = UIColor.whiteColor
    player_icon.layer.cornerRadius = map_icon_diameter / 2
    player_icon.layer.masksToBounds = true
    @mini_map_view.addSubview(player_icon)


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

  def spawn_enemy
    enemy = Enemy.new
    enemy.add_components(@entity_manager)
    node = enemy.set_spawning_location
    @entity_manager.add(enemy)
    @scene.rootNode.addChildNode(node)

    @enemy_icon =  UIView.new
    @enemy_icon.frame = calc_map_frame(node.position)
    @enemy_icon.backgroundColor = UIColor.redColor
    @enemy_icon.layer.cornerRadius = map_icon_diameter / 2
    @enemy_icon.layer.masksToBounds = true
    @mini_map_view.addSubview(@enemy_icon)
    @enemy_map_icons << @enemy_icon
  end

  def calc_map_frame(position)
    x_difference = position.x - @scene_view.pointOfView.position.x
    z_difference = position.z - @scene_view.pointOfView.position.z
    x_map_placement = map_location_to_mini_map_location(x_difference)
    y_map_placement = map_location_to_mini_map_location(z_difference)
    [[x_map_placement, y_map_placement], [map_icon_diameter, map_icon_diameter]]
  end

  def map_location_to_mini_map_location(map_location)
    map_diameter / (Enemy.spawn_radius * 2.0) * map_location + map_diameter / 2.0 - map_icon_diameter / 2.0
  end

  def display_enemies
    @entity_manager.entities.each { |entity| @scene.rootNode.addChildNode(entity)}
  end

  def session(_, didUpdateFrame: _)
    if touching_enemy && !@currently_killing_player
      @currently_killing_player = true
      player_dies
    end
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
      spawn_enemy
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
    bullet = Bullet.new
    @entity_manager.add_bullet(bullet)
    node = bullet.set_firing_location(@scene_view.pointOfView.position)
    @scene.rootNode.addChildNode(node)
  end

  def update_icon_positions
    Dispatch::Queue.main.sync do
     @entity_manager.entities.each.with_index do |enemy, i|
       @mini_map_view.subviews[i + 1].frame = calc_map_frame(enemy.componentForClass(VisualComponent).node.position)
     end
    end
  end

  def renderer(renderer, updateAtTime: time)
    mat = @scene_view.pointOfView.transform
    direction = SCNVector3Make(-3.6 * mat.m31, -3.6 * mat.m32, -3.6 * mat.m33)
    bullet = Bullet.new
    @entity_manager.add_bullet(bullet)
    node = bullet.set_firing_location(direction)
    @scene.rootNode.addChildNode(node)

    update_icon_positions if @enemy_map_icons.count > 0

    @entity_manager.updateWithDeltaTime(time)
  end
end