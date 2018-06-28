class MapViewController < UIViewController

  def viewDidLoad
    super
    self.view = MKMapView.alloc.init
    view.showsUserLocation = true
    view.rotateEnabled     = false
    view.scrollEnabled     = false
    view.showsCompass      = false
    view.zoomEnabled       = false
    view.delegate          = self
    add_ui
  end

  def mapViewDidFinishLoadingMap(_)
    Dispatch::Queue.new('set_map_region_and_tracking_mode').async do
      while parentViewController.current_map_location.nil?; end
      span = MKCoordinateSpanMake(0.0125, 0.0125)
      region = MKCoordinateRegionMake(parentViewController.current_map_location.coordinate, span)
      view.setRegion(region, animated: false)
      view.setUserTrackingMode(MKUserTrackingModeFollowWithHeading, animated: false)
    end
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
  end

  def push_user_to_menu
    parentViewController.set_controller(parentViewController.menu_controller, from: self)
  end

  def touchesEnded(_, withEvent: event)
    if event.touchesForView(@menu_view)
      push_user_to_menu
    end
  end
end