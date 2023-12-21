

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedBrewery: Brewery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.selectedBrewery?.name
        guard let brewery = self.selectedBrewery, let latitudeValue = brewery.latitude, let latitude = Double(latitudeValue), let longtitudeValue = brewery.longtitude, let longtitude = Double(longtitudeValue) else {return}
        self.setupLocation(brewery: brewery, latitude: latitude, longtitude: longtitude)
  }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        navigationItem.title = "Breweries"
    }
    
    private func setupLocation(brewery: Brewery, latitude: Double, longtitude: Double){
        let initialLocation = CLLocation(latitude: latitude, longitude: longtitude)
        mapView.centerToLocation(initialLocation)
        
        let point = MapPointer(
            title: brewery.name,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longtitude))
        mapView.addAnnotation(point)
    }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
