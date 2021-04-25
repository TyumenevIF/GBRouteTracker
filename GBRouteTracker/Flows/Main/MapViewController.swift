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
    let locationManager = LocationManager.instance
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
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                self?.routeLine?.path = self?.routePath
                
                if self?.startTrackButton.isHidden == true {
                    self?.saveToRealm(location)
                }
                
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
            }
    }
    
    // MARK: - Actions
    @IBAction func trackLocation(_ sender: Any) {
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true
        
        routeLine?.map = nil
        routeLine = GMSPolyline()
        routePath = GMSMutablePath()
        routeLine?.map = mapView
        
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func startTrack(_ sender: Any) {
        startTrackButton.isHidden = true
        finishTrackButton.isHidden = false
        
        routeLine?.map = nil
        routeLine = GMSPolyline()
        routePath = GMSMutablePath()
        routeLine?.map = mapView
        
        deletePointFromRealm()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func finishTrack(_ sender: Any) {
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true
        
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func showPreviousTrack(_ sender: Any) {
        if startTrackButton.isHidden == true {
            showAlert()
        }
        
        startTrackButton.isHidden = false
        finishTrackButton.isHidden = true
        
        locationManager.stopUpdatingLocation()
        
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
        
    private func deletePointFromRealm() {
        do {
            let realmPoint = realm.objects(RoutePoint.self)
            try realm.write {
                realm.delete(realmPoint)
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
