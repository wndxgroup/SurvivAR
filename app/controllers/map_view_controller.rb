# class MapViewController < UIViewController
#
#   def viewDidLoad
#     super
#     self.view = MKMapView.alloc.init
#     view.showsUserLocation = true
#     view.rotateEnabled     = false
#     view.scrollEnabled     = false
#     view.showsCompass      = false
#     view.zoomEnabled       = false
#     view.delegate          = self
#     add_ui
#   end
#
#   def mapViewDidFinishLoadingMap(_)
#     Dispatch::Queue.new('set_map_region_and_tracking_mode').async do
#       while parentViewController.current_map_location.nil?; end
#       span = MKCoordinateSpanMake(0.0125, 0.0125)
#       region = MKCoordinateRegionMake(parentViewController.current_map_location.coordinate, span)
#       view.setRegion(region, animated: false)
#       view.setUserTrackingMode(MKUserTrackingModeFollowWithHeading, animated: false)
#     end
#   end
#
#   def add_ui
#     @menu_view = UIView.new
#     view.addSubview(@menu_view)
#     @menu_view.translatesAutoresizingMaskIntoConstraints = false
#     @menu_view.widthAnchor.constraintEqualToConstant(70).active = true
#     @menu_view.heightAnchor.constraintEqualToConstant(70).active = true
#     @menu_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true
#
#     menu_icon = UIImage.imageNamed('menu-button')
#     menu_icon_view = UIImageView.alloc.initWithImage(menu_icon)
#     menu_icon_view.frame = [[0 ,0], [70, 70]]
#     @menu_view.addSubview(menu_icon_view)
#
#     @vision_view = UIView.new
#     view.addSubview(@vision_view)
#     @vision_view.translatesAutoresizingMaskIntoConstraints = false
#     @vision_view.widthAnchor.constraintEqualToConstant(70).active = true
#     @vision_view.heightAnchor.constraintEqualToConstant(70).active = true
#     @vision_view.rightAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.rightAnchor).active = true
#     @vision_view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true
#
#     vision_icon = UIImage.imageNamed('vision-button')
#     vision_icon_view = UIImageView.alloc.initWithImage(vision_icon)
#     vision_icon_view.frame = [[0, 0], [70, 70]]
#     @vision_view.addSubview(vision_icon_view)
#   end
#
#   def push_user_to_menu
#     parentViewController.set_controller(parentViewController.menu_controller, from: self)
#   end
#
#   def push_user_to_vision
#     unless parentViewController.ar_view_controller
#       parentViewController.start_vision(self)
#     else
#       parentViewController.set_controller(parentViewController.ar_view_controller, from: self)
#     end
#   end
#
#   def touchesEnded(_, withEvent: event)
#     if event.touchesForView(@menu_view)
#       push_user_to_menu
#     elsif event.touchesForView(@vision_view)
#       push_user_to_vision
#     end
#   end
# end