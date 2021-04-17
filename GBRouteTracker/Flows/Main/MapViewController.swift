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
    var locationManager: CLLocationManager?
    var routeLine: GMSPolyline?
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
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestAlwaysAuthorization()
    }
    
    // MARK: - Actions
    @IBAction func trackLocation(_ sender: Any) {
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true
        
        routeLine?.map = nil
        routeLine = GMSPolyline()
        routePath = GMSMutablePath()
        routeLine?.map = mapView
        
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
    }
    
    @IBAction func startTrack(_ sender: Any) {
        startTrackButton.isHidden = true
        finishTrackButton.isHidden = false

        routeLine?.map = nil
        routeLine = GMSPolyline()
        routePath = GMSMutablePath()
        routeLine?.map = mapView
        
        deleteAllFromRealm()
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
    }
    
    @IBAction func finishTrack(_ sender: Any) {
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true
        
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
    }
    
    @IBAction func showPreviousTrack(_ sender: Any) {
        if startTrackButton.isHidden == true {
            showAlert()
        }
        
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true
        
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        
        routeLine = GMSPolyline()
        routePath = GMSMutablePath()
        let realmRoutePoint = realm.objects(RoutePoint.self)
        for point in realmRoutePoint {
            let coord = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            routePath?.add(coord)
        }
        routeLine?.path = routePath
        routeLine?.map = mapView
        
        let bounds = GMSCoordinateBounds(path: routePath ?? GMSMutablePath())
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    private func saveToRealm(_ location: CLLocation) {
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
        
    private func deleteAllFromRealm() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Уведомление",
            message: "Слежение будет остановлено",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Extensions
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        routePath?.add(location.coordinate)
        routeLine?.path = routePath
        
        if startTrackButton.isHidden == true {
            saveToRealm(location)
        }

        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: camera)
        print(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
