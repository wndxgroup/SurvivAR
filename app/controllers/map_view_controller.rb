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
end