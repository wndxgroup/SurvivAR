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
    @enemy_queue = Dispatch::Queue.new('enemies')
    @bullet_queue = Dispatch::Queue.new('bullets')
    self
  end

  def viewDidLoad
    super
    navigationController.setNavigationBarHidden(true, animated: true)
    @scene_view = ARSCNView.alloc.init
    @scene_view.autoenablesDefaultLighting = true
    @scene_view.delegate = self
    @scene_config = ARWorldTrackingConfiguration.alloc.init
    @scene_config.worldAlignment = ARWorldAlignmentGravityAndHeading
    # @scene_view.debugOptions = ARSCNDebugOptionShowWorldOrigin
    @scene_view.session.runWithConfiguration(@scene_config)
    @scene_view.session.delegate = self
    self.view = @scene_view
    view.backgroundColor = UIColor.blackColor

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
    @player.battling = true
    @player.start_survival_session
  end

  def viewDidAppear(_)
    add_ui
    @bullets = []
    @scene_view.session.runWithConfiguration(@scene_config, options: ARSessionRunOptionResetTracking)
    @currently_killing_player = false
    if @player.savedEnemies.count > 0
      display_enemies
    else
      spawn_enemy
    end
  end

  def add_ui
    info_bar = UIView.new
    info_bar.backgroundColor = UIColor.alloc.initWithWhite(0, alpha: 0.5)
    info_bar.layer.borderWidth = 2
    info_bar.layer.borderColor = UIColor.blackColor.CGColor
    @scene_view.addSubview(info_bar)
    info_bar.translatesAutoresizingMaskIntoConstraints = false
    info_bar.leftAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.leftAnchor).active = true
    info_bar.rightAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.rightAnchor).active = true
    info_bar.topAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.topAnchor).active = true
    info_bar.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.topAnchor, constant: 40).active = true

    username = UILabel.new
    username.text = @player.username
    username.frame = [[10, 0], [@scene_view.frame.size.width / 3.0 - 10, 40]]
    username.textColor = UIColor.whiteColor
    info_bar.addSubview(username)

    @kill_count = UILabel.new
    @kill_count.text = @player.kills.to_s
    @kill_count.frame = [[@scene_view.frame.size.width / 3.0, 0], [@scene_view.frame.size.width / 3.0, 40]]
    @kill_count.textAlignment = NSTextAlignmentCenter
    @kill_count.textColor = UIColor.whiteColor
    info_bar.addSubview(@kill_count)

    @survival_clock = UILabel.new
    @survival_clock.text = survival_time(@player)
    @survival_clock.frame = [[@scene_view.frame.size.width / 3.0 * 2, 0], [@scene_view.frame.size.width / 3.0 - 10, 40]]
    @survival_clock.textAlignment = NSTextAlignmentRight
    @survival_clock.textColor = UIColor.whiteColor
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
    @mini_map_view.layer.borderWidth = 2
    @mini_map_view.layer.borderColor = UIColor.blackColor.CGColor
    view.addSubview(@mini_map_view)

    player_icon =  UIView.new
    player_icon.frame = [[mini_map_diameter / 2.0 - map_icon_diameter / 2.0, mini_map_diameter / 2.0 - map_icon_diameter / 2.0],
                         [map_icon_diameter, map_icon_diameter]]
    player_icon.backgroundColor = UIColor.whiteColor
    player_icon.layer.cornerRadius = map_icon_diameter / 2.0
    player_icon.layer.masksToBounds = true
    @mini_map_view.addSubview(player_icon)

    toggle_button_width = 60
    @toggle_button = UIButton.new
    @toggle_button.frame = [[@scene_view.frame.size.width / 2.0 - toggle_button_width / 2.0, @scene_view.frame.size.height - toggle_button_width * 2],
                            [toggle_button_width, toggle_button_width]]
    @toggle_button.setImage(UIImage.imageNamed('pause'), forState: UIControlStateNormal)
    view.addSubview(@toggle_button)
    @toggle_button.addTarget(self, action: 'stop_time', forControlEvents: UIControlEventTouchUpInside)

    menu_button = UIButton.new
    menu_button.frame = [[@scene_view.frame.size.width / 2.0 - toggle_button_width / 2.0, @scene_view.frame.size.height - toggle_button_width],
                         [toggle_button_width, toggle_button_width]]
    menu_button.setImage(UIImage.imageNamed('menu-button'), forState: UIControlStateNormal)
    view.addSubview(menu_button)
    menu_button.addTarget(self, action: 'go_to_menu', forControlEvents: UIControlEventTouchUpInside)
  end

  def stop_time
    @scene.rootNode.paused = true
    @toggle_button.removeFromSuperview
    Dispatch::Queue.new('stop time').async do
      sleep 5
      @scene.rootNode.paused = false
      sleep 55
      view.addSubview(@toggle_button)
    end
  end

  def go_to_menu
    puts 'saving'
    save_enemy_data
    puts 'saved'
    pause_session
    navigationController.setViewControllers([MenuController.new], animated: true)
  end

  def spawn_enemy
    @enemy_queue.async do
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
    @player.savedEnemies.array.each do |e|
      enemy = Enemy.new
      enemy.add_components(@entity_manager)
      x = e.x
      z = e.z
      node = enemy.set_spawning_location(x, z)
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
    @player.savedEnemies.remove_all
    cdq.save
  end

  def player_dies
    Dispatch::Queue.main.sync do
      @player.battling = false
      @player.alive = false
      @player.rounds.create(kills: @player.kills, survival_time: survival_time(@player), completed_on: Time.now)
      @player.savedEnemies.array.each {|e| e.destroy}
      cdq.save
      push_user_to_death_screen
    end
  end

  def touchesEnded(_, withEvent: event)
    if event.touchesForView(@scene_view) && !@scene.rootNode.isPaused
      # spawn_enemy
      # shoot
    end
  end

  def push_user_to_death_screen
    pause_session
    navigationController.setViewControllers([DeathController.new], animated: true)
  end

  def save_enemy_data
    @entity_manager.entities.each do |entity|
      x = entity.node.presentationNode.position.x
      z = entity.node.presentationNode.position.z
      @player.savedEnemies.create(x: x, z: z)
      cdq.save
    end
  end

  def pause_session
    # @scene_view.pointOfView.childNodes.each {|node| node.removeFromParentNode} # does this do anything?
    @player.battling = false
    cdq.save
    @mini_map_view.subviews.each_with_index {|view, index| view.removeFromSuperview if index > 0}
    @scene.rootNode.childNodes.each {|node| node.removeFromParentNode}
    @scene_view.session.pause
  end

  def shoot
    @bullet_queue.async do
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

    return if @scene.rootNode.isPaused
    update_survival_clock_display
    update_icon_positions if @enemy_map_icons.count > 0
    @entity_manager.updateWithDeltaTime(time)
  end

  def update_survival_clock_display
    Dispatch::Queue.main.sync {@survival_clock.text = survival_time(@player)} if @survival_clock
  end

  def update_icon_positions
    Dispatch::Queue.main.sync do
      @entity_manager.entities.each.with_index do |enemy, i|
        if @mini_map_view.subviews[i + 1]
          @mini_map_view.subviews[i + 1].frame = calc_map_frame(enemy.componentForClass(VisualComponent).node.position)
        end
      end
    end
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
    survivor_node = @survivor.componentForClass(LocationComponent).node
    if (contact.nodeA == survivor_node || contact.nodeB == survivor_node) && !@currently_killing_player
      @currently_killing_player = true
      player_dies
    elsif @enemy.componentForClass(VisualComponent).state_machine.currentState.is_a?(EnemyChaseState)
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
    if @mini_map_view
      @mini_map_view.layer.transform = CATransform3DMakeRotation(-new_heading.trueHeading / 180.0  * Math::PI, 0.0, 0.0, 1.0);
    end
  end
end