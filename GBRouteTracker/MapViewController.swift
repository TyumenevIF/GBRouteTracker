//
//  ViewController.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 03.04.2021.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    var firstCoordinate = CLLocationCoordinate2D(latitude: 55.7522200, longitude: 37.6155600)
    var locationManager: CLLocationManager = CLLocationManager()
    var marker: GMSMarker?
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: firstCoordinate, zoom: 13)
        mapView.camera = camera
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Actions
    @IBAction func trackLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
}

// MARK: - Extensions
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let initialLocation = CLLocationCoordinate2D(
            latitude: locations[0].coordinate.latitude,
            longitude: locations[0].coordinate.longitude
        )
        let marker = GMSMarker(position: initialLocation)
        marker.map = mapView
        
        let camera = GMSCameraPosition.camera(withTarget: initialLocation, zoom: 17)
        mapView.camera = camera
        print(locations[0])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
