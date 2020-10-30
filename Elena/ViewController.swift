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

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var savedRoutesButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bottomShelf: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var inclineLabel: UILabel!
    @IBOutlet weak var elevationGainLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    var destLocation: CLLocation!
    
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
            mapView.showsUserLocation = true
        } else {
            // User denied us and we're screwed
        }
        
        // Amherst Lat/long: 42.3732, -72.5199
        //mapView.centerToLocation(CLLocation(latitude: 42.3732, longitude: -72.5199))
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleMapPress(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        searchField.returnKeyType = .route
        searchField.delegate = self
    }
    
    @objc func handleMapPress(_ gestureReconizer: UITapGestureRecognizer) {
        
        // Remove current annotation
        mapView.removeAnnotations(mapView.annotations)
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        destLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func onSettingsTap(_ sender: UIButton) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    @IBAction func onSavedTap(_ sender: UIButton) {
        performSegue(withIdentifier: "toSavedRoutes", sender: self)
    }
    
    @IBAction func onGoTap(_ sender: UIButton) {
        
        // Do validation check on destination
        
        
        // An example of how to use the getStreet method to get location names from lat/long
        getStreet(from: currentLocation, completion: {
            placemarks, error in
            
            guard let placeMark = placemarks?.first else { return }
            
            // Location name
            if let locationName = placeMark.location {
                print(locationName)
            }
            // Street address
            if let street = placeMark.thoroughfare {
                print(street)
            }
            // City
            if let city = placeMark.subAdministrativeArea {
                print(city)
            }
            // Zip code
            if let zip = placeMark.isoCountryCode {
                print(zip)
            }
            // Country
            if let country = placeMark.country {
                print(country)
            }
            
            
        })
        
        sendToBackend()
    }
    
    
    func sendToBackend() {
        
        let requestURL = "http://something.com/route"
        
        let Url = String(format: requestURL)
        guard let serviceUrl = URL(string: Url) else { return }
        let parameters: [String: Any] = [
            "start": "",
            "dest": "",
            "goal": "Minimize Elevation Gain",
            "limit": "0",
            "algorithm": "AStar",
            "method": "drive"
        ]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        request.timeoutInterval = 20
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    // Success!
                    
                    print(json)
                } catch {
                    
                    // Error
                    
                    print(error)
                }
            }
        }.resume()
        
    }
    
    
    func getStreet(from location: CLLocation, completion: @escaping (([CLPlacemark]?, Error?) -> ())) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error -> Void in
            completion(placemarks, error)
        })
    }
    
    
    // Update map with current location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        mapView.centerToLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
        currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
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

