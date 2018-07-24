class ARViewController < UIViewController
  include Map, SurvivalTime
  attr_accessor :scene_view, :scene_config, :mini_map_view

  def enemy_radius; 1.0; end
  def map_icon_diameter; 10; end

  def init
    super
    @enemy_map_icons = []
    @location_manager = CLLocationManager.alloc.init
    @location_manager.startUpdatingHeading
    @location_manager.delegate = self
    @location_manager.requestAlwaysAuthorization
    self
  end

  def viewDidLoad
    super
    puts 'viewDidLoad'
    @scene_view = ARSCNView.alloc.init
    @scene_view.autoenablesDefaultLighting = true
    @scene_view.delegate = self
    @scene_config = ARWorldTrackingConfiguration.alloc.init
    @scene_config.worldAlignment = ARWorldAlignmentGravityAndHeading
    # @scene_view.debugOptions = ARSCNDebugOptionShowWorldOrigin
    @scene_view.session.runWithConfiguration(@scene_config)
    @scene_view.session.delegate = self
    self.view = @scene_view

    @scene = SCNScene.scene
    @scene.physicsWorld.contactDelegate = self
    @entity_manager = EntityManager.alloc.init(@scene, @scene_view, self)
    @scene_view.scene = @scene

    @survivor = Survivor.new
    node = @survivor.survivor_node
    @scene.rootNode.addChildNode(node)
    @entity_manager.assign_survivor(@survivor)

    player = Player.first
    @player = player.sorted_accounts[player.current_account]
  end

  def viewDidAppear(_)
    puts 'viewDidAppear'
    add_ui
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
    info_bar = UIView.new
    info_bar.frame = [[0, 0], [@scene_view.frame.size.width, 40]]
    info_bar.backgroundColor = UIColor.alloc.initWithRed(0, green: 0, blue: 0, alpha: 0.5)
    @scene_view.addSubview(info_bar)

    username = UILabel.new
    username.text = @player.username
    username.textColor = UIColor.whiteColor
    username.frame = [[10, 0], [@scene_view.frame.size.width / 3.0 - 10, 40]]
    info_bar.addSubview(username)

    @kill_count = UILabel.new
    @kill_count.text = @player.kills.to_s
    @kill_count.textColor = UIColor.whiteColor
    @kill_count.frame = [[@scene_view.frame.size.width / 3.0, 0], [@scene_view.frame.size.width / 3.0, 40]]
    @kill_count.textAlignment = NSTextAlignmentCenter
    info_bar.addSubview(@kill_count)

    @survival_clock = UILabel.new
    @survival_clock.text = survival_time(@player)
    @survival_clock.textColor = UIColor.whiteColor
    @survival_clock.frame = [[@scene_view.frame.size.width / 3.0 * 2, 0], [@scene_view.frame.size.width / 3.0 - 10, 40]]
    @survival_clock.textAlignment = NSTextAlignmentRight
    info_bar.addSubview(@survival_clock)

    scope_width = 120
    scope_icon = UIImage.imageNamed('scope')
    scope_icon_view = UIImageView.alloc.initWithImage(scope_icon)
    scope_icon_view.frame = [[@scene_view.frame.size.width / 2.0 - scope_width / 2.0, @scene_view.frame.size.height / 2.0 - scope_width / 2.0],
                             [scope_width, scope_width]]
    @scene_view.addSubview(scope_icon_view)

    @mini_map_view = UIView.new
    @mini_map_view.backgroundColor = UIColor.alloc.initWithWhite(0, alpha: 0.5)
    @mini_map_view.layer.cornerRadius = mini_map_diameter / 2.0
    @mini_map_view.layer.masksToBounds = true
    @mini_map_view.frame = [[0, @scene_view.frame.size.height - mini_map_diameter], [mini_map_diameter, mini_map_diameter]]
    view.addSubview(@mini_map_view)

    player_icon =  UIView.new
    player_icon.frame = [[mini_map_diameter / 2.0 - map_icon_diameter / 2.0, mini_map_diameter / 2.0 - map_icon_diameter / 2.0],
                         [map_icon_diameter, map_icon_diameter]]
    player_icon.backgroundColor = UIColor.whiteColor
    player_icon.layer.cornerRadius = map_icon_diameter / 2.0
    player_icon.layer.masksToBounds = true
    @mini_map_view.addSubview(player_icon)

    toggle_button_width = 60
    toggle_button = UIImage.imageNamed('pause')
    @toggle_button_view = UIView.new
    @toggle_button_view.frame = [[@scene_view.frame.size.width / 2.0 - toggle_button_width / 2.0, @scene_view.frame.size.height - toggle_button_width],
                                 [toggle_button_width, toggle_button_width]]
    toggle_image_view = UIImageView.alloc.initWithImage(toggle_button)
    toggle_image_view.frame = [[0, 0], [toggle_button_width, toggle_button_width]]
    @toggle_button_view.addSubview(toggle_image_view)
    @scene_view.addSubview(@toggle_button_view)
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
    mini_map_diameter / (spawn_radius * 2.0) * map_location + mini_map_diameter / 2.0 - map_icon_diameter / 2.0
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
    @player.alive = false
    @player.start_time = nil
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
    if event.touchesForView(@toggle_button_view)
      puts 'pause'
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
    @scene_view.pointOfView.childNodes.each {|node| node.removeFromParentNode} # does this do anything?
    @scene.rootNode.childNodes.each {|node| node.removeFromParentNode}
    @scene_view.session.pause
  end

  def shoot
    target = SCNNode.node
    target.position = [0, 0, -80]

    @scene_view.pointOfView.addChildNode(target)
    user_position = @scene_view.pointOfView.position
    target_position = @scene_view.pointOfView.convertPosition(target.position, toNode: nil)
    @scene_view.pointOfView.childNodes[0].removeFromParentNode

    bullet = Bullet.new
    @entity_manager.add_bullet(bullet)
    node = bullet.set_firing_location(user_position)
    force = [target_position.x, target_position.y, target_position.z]
    node.physicsBody.applyForce(force, atPosition: [0, 0, 0], impulse: true)
    @scene.rootNode.addChildNode(node)
  end

  def update_icon_positions
    Dispatch::Queue.main.sync do
      @entity_manager.entities.each.with_index do |enemy, i|
        @mini_map_view.subviews[i + 1].frame = calc_map_frame(enemy.componentForClass(VisualComponent).node.position)
      end
    end
  end

  def renderer(_, updateAtTime: time)
    # mat = @scene_view.pointOfView.transform
    # direction = SCNVector3Make(-3.6 * mat.m31, -3.6 * mat.m32, -3.6 * mat.m33)
    # puts direction.inspect
    # bullet = Bullet.new
    # @entity_manager.add_bullet(bullet)
    # node = bullet.set_firing_location(direction)
    # @scene.rootNode.addChildNode(node)

    # d = radians_away_from_facing_north
    # puts d
    # Dispatch::Queue.main.sync { @mini_map_view.layer.transform = CATransform3DMakeRotation(-d, 0.0, 0.0, 1.0) }
    update_survival_clock_display
    update_icon_positions if @enemy_map_icons.count > 0
    @entity_manager.updateWithDeltaTime(time)
  end

  def update_survival_clock_display
    Dispatch::Queue.main.sync { @survival_clock.text = survival_time(@player) } if @survival_clock
  end

  def increment_kill_count
    Dispatch::Queue.main.sync do
      @player.kills += 1
      cdq.save
      @kill_count.text = @player.kills.to_s
    end
  end

  def physicsWorld(world, didBeginContact: contact)
    @entity_manager.entities.each {|enemy| @enemy = enemy if enemy.node == contact.nodeA || enemy.node == contact.nodeB}
    if @enemy && @enemy.componentForClass(VisualComponent).state_machine.currentState.is_a?(EnemyChaseState)
      @enemy.componentForClass(VisualComponent).state_machine.enterState(EnemyFleeState)
      increment_kill_count
    end
  end

  def viewWillDisappear(_)
    puts 'willDisappear'
  end

  def sessionWasInterrupted(_)
    puts 'interupted'
  end

  def sessionInterruptionEnded(_)
    puts 'ended'
  end

  def locationManager(_, didUpdateHeading: new_heading)
    @mini_map_view.layer.transform = CATransform3DMakeRotation(-new_heading.trueHeading / 180.0  * Math::PI, 0.0, 0.0, 1.0);
  end
end