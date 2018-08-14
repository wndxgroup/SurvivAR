class BattlegroundController < UIViewController
  include Map, SurvivalTime, Sounds
  attr_accessor :mini_map_view

  def enemy_radius; 1.0; end
  def map_icon_diameter; 10; end

  def init
    super
    @enemy_map_icons = []
    @location_manager = CLLocationManager.new
    @location_manager.delegate = self
    @location_manager.requestWhenInUseAuthorization
    @enemy_queue = Dispatch::Queue.new('enemies')
    @bullet_queue = Dispatch::Queue.new('bullets')
    self
  end

  def viewDidLoad
    super
    navigationController.setNavigationBarHidden(true, animated: true)
    @spawning_enemy = true
    @scene_view = ARSCNView.new
    @scene_view.autoenablesDefaultLighting = true
    @scene_view.delegate = self
    @scene_config = ARWorldTrackingConfiguration.new
    @scene_config.worldAlignment = ARWorldAlignmentGravityAndHeading
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
    @account = player.sorted_accounts[player.current_account]
    @account.battling = true
    @account.start_survival_session
    play_wave_sound if survival_time(@account).split(':')[-1].to_i < 3
  end

  def viewDidAppear(_)
    add_ui
    @location_manager.startUpdatingHeading
    @bullets = []
    @scene_view.session.runWithConfiguration(@scene_config, options: ARSessionRunOptionResetTracking)
    @scene.rootNode.paused = false if @account.time_froze_at && time_frozen_for < 5
    @currently_killing_player = false
    if @account.savedEnemies.count > 0
      display_enemies
    else
      @spawning_enemy = false
    end
  end

  def add_ui
    info_bar_height = 40

    info_bar = UIView.new
    info_bar.backgroundColor = UIColor.alloc.initWithWhite(1, alpha: 0.8)
    info_bar.layer.borderWidth = 2
    info_bar.layer.borderColor = UIColor.blackColor.CGColor
    @scene_view.addSubview(info_bar)
    info_bar.translatesAutoresizingMaskIntoConstraints = false
    guide = view.safeAreaLayoutGuide
    info_bar.leftAnchor  .constraintEqualToAnchor(guide.leftAnchor)                          .active = true
    info_bar.rightAnchor .constraintEqualToAnchor(guide.rightAnchor)                         .active = true
    info_bar.topAnchor   .constraintEqualToAnchor(guide.topAnchor)                           .active = true
    info_bar.bottomAnchor.constraintEqualToAnchor(guide.topAnchor, constant: info_bar_height).active = true

    username = UILabel.new
    username.text = @account.username
    username.frame = [[10, 0], [@scene_view.frame.size.width / 3.0 - 10, info_bar_height]]
    info_bar.addSubview(username)

    @kill_count = UILabel.new
    @kill_count.text = @account.kills.to_s
    @kill_count.frame = [[@scene_view.frame.size.width / 3.0, 0],
                         [@scene_view.frame.size.width / 3.0, info_bar_height]]
    @kill_count.textAlignment = NSTextAlignmentCenter
    info_bar.addSubview(@kill_count)

    @survival_clock = UILabel.new
    @survival_clock.text = survival_time(@account)
    @survival_clock.frame = [[@scene_view.frame.size.width / 3.0 * 2, 0],
                             [@scene_view.frame.size.width / 3.0 - 10, info_bar_height]]
    @survival_clock.textAlignment = NSTextAlignmentRight
    info_bar.addSubview(@survival_clock)

    scope_width = 120
    scope_icon = UIImage.imageNamed('scope')
    scope_icon_view = UIImageView.alloc.initWithImage(scope_icon)
    scope_icon_view.frame = [[@scene_view.frame.size.width / 2.0 - scope_width / 2.0,
                              @scene_view.frame.size.height / 2.0 - scope_width / 2.0],
                             [scope_width, scope_width]]
    @scene_view.addSubview(scope_icon_view)

    @mini_map_view = UIView.new
    @mini_map_view.backgroundColor = UIColor.alloc.initWithWhite(0, alpha: 0.5)
    @mini_map_view.layer.cornerRadius = mini_map_diameter / 2.0
    @mini_map_view.layer.masksToBounds = true
    @mini_map_view.frame = [[0, @scene_view.frame.size.height - mini_map_diameter],
                            [mini_map_diameter, mini_map_diameter]]
    @mini_map_view.layer.borderWidth = 2
    @mini_map_view.layer.borderColor = UIColor.blackColor.CGColor
    view.addSubview(@mini_map_view)

    player_icon =  UIView.new
    player_icon.frame = [[mini_map_diameter / 2.0 - map_icon_diameter / 2.0,
                          mini_map_diameter / 2.0 - map_icon_diameter / 2.0],
                         [map_icon_diameter, map_icon_diameter]]
    player_icon.backgroundColor = UIColor.whiteColor
    player_icon.layer.cornerRadius = map_icon_diameter / 2.0
    player_icon.layer.masksToBounds = true
    @mini_map_view.addSubview(player_icon)

    toggle_button_width = 60
    @freeze_button = UIButton.new
    @freeze_button.frame = [[@scene_view.frame.size.width / 2.0 - toggle_button_width / 2.0,
                             @scene_view.frame.size.height - toggle_button_width * 2],
                            [toggle_button_width, toggle_button_width]]
    @freeze_button.setImage(UIImage.imageNamed('pause'), forState: UIControlStateNormal)
    view.addSubview(@freeze_button) unless @account.time_froze_at
    @freeze_button.addTarget(self, action: 'stop_time', forControlEvents: UIControlEventTouchUpInside)

    menu_button = UIButton.new
    menu_button.frame = [[@scene_view.frame.size.width / 2.0 - toggle_button_width / 2.0,
                          @scene_view.frame.size.height - toggle_button_width],
                         [toggle_button_width, toggle_button_width]]
    menu_button.setImage(UIImage.imageNamed('menu-button'), forState: UIControlStateNormal)
    view.addSubview(menu_button)
    menu_button.addTarget(self, action: 'go_to_menu', forControlEvents: UIControlEventTouchUpInside)
  end

  def stop_time
    play_freeze_sound
    @scene.rootNode.paused = true
    @freeze_button.removeFromSuperview
    @account.time_froze_at = survival_time(@account)
    cdq.save
  end

  def go_to_menu
    save_enemy_data
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
      add_enemy_map_icon(node)
      @spawning_enemy = false
    end
  end

  def add_enemy_map_icon(node)
    enemy_icon =  UIView.new
    enemy_icon.frame = calc_map_frame(node.position)
    enemy_icon.backgroundColor = UIColor.redColor
    enemy_icon.layer.cornerRadius = map_icon_diameter / 2.0
    enemy_icon.layer.masksToBounds = true
    @mini_map_view.addSubview(enemy_icon)
    @enemy_map_icons << enemy_icon
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
    @account.savedEnemies.array.each do |e|
      enemy = Enemy.new
      enemy.add_components(@entity_manager)
      node = enemy.set_spawning_location(e.x, e.z)
      @entity_manager.add(enemy)
      @scene.rootNode.addChildNode(node)
      add_enemy_map_icon(node)
    end
    @account.savedEnemies.remove_all
    cdq.save
  end

  def player_dies
    Dispatch::Queue.main.async do
      @account.battling = @account.alive = false
      @account.time_froze_at = nil
      @account.rounds.create(kills: @account.kills, survival_time: survival_time(@account), completed_on: Time.now)
      @account.kills = @account.seconds = @account.minutes = @account.hours = 0
      @account.savedEnemies.array.each {|e| e.destroy}
      cdq.save
      pause_session
      navigationController.setViewControllers([DeathController.new], animated: true)
    end
  end

  def touchesEnded(_, withEvent: event)
    if event.touchesForView(@scene_view) && !@scene.rootNode.isPaused
      spawn_enemy
      shoot
    end
  end

  def save_enemy_data
    @entity_manager.entities.each do |entity|
      if entity.componentForClass(VisualComponent).state_machine.currentState.is_a?(EnemyChaseState)
        position = entity.node.presentationNode.position
        @account.savedEnemies.create(x: position.x, z: position.z)
        cdq.save
      end
    end
  end

  def pause_session
    @account.battling = false
    cdq.save
    @mini_map_view.subviews.each_with_index {|view, index| view.removeFromSuperview if index > 0} if @mini_map_view
    @scene.rootNode.childNodes.each {|node| node.removeFromParentNode}
    @scene_view.session.pause
  end

  def shoot
    play_shoot_sound
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
    update_survival_clock_display
    unfreeze_time if @account.time_froze_at && time_frozen_for >= 5
    return if @scene.rootNode.isPaused
    if @entity_manager.entities.count == 0 && !@spawning_enemy
      @spawning_enemy = true
      spawn_enemy
    end
    recharge_freeze_ability if @account.time_froze_at && time_frozen_for >= 60
    update_icon_positions if @enemy_map_icons.count > 0
    @entity_manager.updateWithDeltaTime(time)
  end

  def unfreeze_time
    Dispatch::Queue.main.async { @scene.rootNode.paused = false }
  end

  def recharge_freeze_ability
    Dispatch::Queue.main.async do
      view.addSubview(@freeze_button)
      @account.time_froze_at = nil
      cdq.save
    end
  end

  def time_frozen_for
    curr_time   = survival_time(@account).split(':').map {|time| time.to_i}
    frozen_time = @account.time_froze_at .split(':').map {|time| time.to_i}
    curr_time[2]- frozen_time[2] + 60 * (curr_time[1] - frozen_time[1]) + 60 * 60 * (curr_time[0] - frozen_time[0])
  end

  def update_survival_clock_display
    Dispatch::Queue.main.async { @survival_clock.text = survival_time(@account) } if @survival_clock
  end

  def update_icon_positions
    Dispatch::Queue.main.async do
      @entity_manager.entities.each.with_index do |enemy, i|
        if @mini_map_view.subviews[i + 1]
          @mini_map_view.subviews[i + 1].frame = calc_map_frame(enemy.componentForClass(VisualComponent).node.position)
        end
      end
    end
  end

  def increment_kill_count
    Dispatch::Queue.main.async do
      @account.kills += 1
      cdq.save
      @kill_count.text = @account.kills.to_s
    end
  end

  def physicsWorld(_, didBeginContact: contact)
    @entity_manager.entities.each {|enemy| @enemy = enemy if enemy.node == contact.nodeA || enemy.node == contact.nodeB}
    survivor_node = @survivor.componentForClass(LocationComponent).node
    if (contact.nodeA == survivor_node || contact.nodeB == survivor_node) && !@currently_killing_player
      @currently_killing_player = true
      player_dies
    elsif @enemy.componentForClass(VisualComponent).state_machine.currentState.is_a?(EnemyChaseState) && !@currently_killing_player
      @enemy.componentForClass(VisualComponent).state_machine.enterState(EnemyFleeState)
      increment_kill_count
    end
  end

  def locationManager(_, didUpdateHeading: new_heading)
    @mini_map_view.layer.transform = CATransform3DMakeRotation(-new_heading.trueHeading / 180.0  * Math::PI, 0.0, 0.0, 1.0)
  end
end