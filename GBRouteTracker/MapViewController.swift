//
//  ViewController.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 03.04.2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class MapViewController: UIViewController {
    
    var firstCoordinate = CLLocationCoordinate2D(latitude: 55.7522200, longitude: 37.6155600)
    var locationManager: CLLocationManager = CLLocationManager()
    var marker: GMSMarker?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    lazy var realm = try! Realm()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!    
    @IBOutlet weak var startTrackButton: UIButton!
    @IBOutlet weak var finishTrackButton: UIButton!
    @IBOutlet weak var previousTrackButton: UIButton!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        finishTrackButton.isHidden = true
        configureMap()
        configureLocationManager()
    }
    
    func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: firstCoordinate, zoom: 13)
        mapView.camera = camera
        mapView.addSubview(startTrackButton)
        mapView.addSubview(finishTrackButton)
        mapView.addSubview(previousTrackButton)
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Actions
    @IBAction func trackLocation(_ sender: Any) {
        startTrackButton.isHidden = true
        finishTrackButton.isHidden = false
        
        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        
        deleteAllFromRealm()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func startTrack(_ sender: Any) {
        startTrackButton.isHidden = true
        finishTrackButton.isHidden = false

        route?.map = nil
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        
        deleteAllFromRealm()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func finishTrack(_ sender: Any) {
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true
        
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func showPreviousTrack(_ sender: Any) {
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true

        locationManager.stopUpdatingLocation()
        
        route?.map = mapView
        let bounds = GMSCoordinateBounds(path: routePath ?? GMSMutablePath())
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    func saveToRealm(_ location: CLLocation) {
        do {
            let realm = try Realm()
            let routePoint = RoutePoint(location: location)
            
            try realm.write {
                realm.add(routePoint)
            }
        } catch {
            print(error)
        }
    }
    
    func deleteAllFromRealm() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}

// MARK: - Extensions
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        routePath?.add(location.coordinate)
        route?.path = routePath
        saveToRealm(location)

        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: camera)
        print(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
