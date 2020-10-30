//
//  ViewController.swift
//  Elena
//
//  Created by Maxwell Hubbard on 10/11/20.
//

import UIKit
import MapKit
import CoreLocation

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 5000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var savedRoutesButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bottomShelf: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var inclineLabel: UILabel!
    @IBOutlet weak var elevationGainLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        // Make the buttons round
        settingsButton.layer.cornerRadius = settingsButton.frame.width / 2
        savedRoutesButton.layer.cornerRadius = savedRoutesButton.frame.width / 2
        
        // Make the bottom rounded
        bottomShelf.layer.cornerRadius = bottomShelf.frame.width / 9
        
        // initialize location services

        // Ask for permission for use in foreground
        self.locationManager.requestAlwaysAuthorization() 
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            // User denied us and we're screwed
        }
        
        // Amherst Lat/long: 42.3732, -72.5199
        //mapView.centerToLocation(CLLocation(latitude: 42.3732, longitude: -72.5199))
        
        
        
        searchField.returnKeyType = .route
        searchField.delegate = self
    }
    
    
    @IBAction func onSettingsTap(_ sender: UIButton) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    // Update map with current location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        mapView.centerToLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Called when route button is pressed
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

