//
//  ViewController.swift
//  Elena
//
//  Created by Maxwell Hubbard on 10/11/20.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

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

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate{
    
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
        
        mapView.delegate = self
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
        
        mapView.removeOverlays(mapView.overlays)
        
        // Do validation check on destination
        var destLoc = ""
        var startLoc = ""
        
        // An example of how to use the getStreet method to get location names from lat/long
        getStreet(from: destLocation, completion: {
            placemarks, error in
            
            guard let placeMark = placemarks?.first else { return }
            
            
            // Full Address
            if let postalAddress = placeMark.postalAddress {
                let streets = postalAddress.street.split(separator: "–", maxSplits: 1, omittingEmptySubsequences: false)
                print(postalAddress)
                if streets.count > 1{
                    let removedHyphen = streets[1].split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                    destLoc = streets[0] + " " + removedHyphen[1] + ", " + postalAddress.city + ", " + postalAddress.state
                } else {
                    destLoc = streets[0] + ", " + postalAddress.city + ", " + postalAddress.state
                }
                print(destLoc)
                
                if !startLoc.isEmpty {
                    self.sendToBackend(starting: startLoc, ending: destLoc)
                }
            }
            
            
            
            
        })
        
        getStreet(from: currentLocation, completion: {
            placemarks, error in
            
            guard let placeMark = placemarks?.first else { return }
            
            
            // Full Address
            if let postalAddress = placeMark.postalAddress {
                let streets = postalAddress.street.split(separator: "–", maxSplits: 1, omittingEmptySubsequences: false)
                if streets.count > 1{
                    let removedHyphen = streets[1].split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                    startLoc = streets[0] + " " + removedHyphen[1] + ", " + postalAddress.city + ", " + postalAddress.state
                } else {
                    startLoc = streets[0] + ", " + postalAddress.city + ", " + postalAddress.state
                }
                print(startLoc)
                
                if !destLoc.isEmpty {
                    self.sendToBackend(starting: startLoc, ending: destLoc)
                }
            }

        })
        
    }
    
    
    func sendToBackend(starting: String, ending: String) {
        
        let requestURL = "http://165.227.197.221:5000/route"
        
        let Url = String(format: requestURL)
        guard let serviceUrl = URL(string: Url) else { return }
        let parameters: [String: Any] = [
            "start": starting,
            "dest": ending,
            "goal": "Minimize Elevation Gain",
            "limit": "110",
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
                    self.displayRoute(json: json)
                    
                } catch {
                    
                    // Error
                    
                    print(error)
                }
            }
        }.resume()
        
    }
    
    func displayRoute(json: Any) {
        
        if let dictionary = json as? [String: Any] {
            
            // 2D array of strings. path[0] is a [string] of ['long','lat']
            let path: [[Double]] = dictionary["path"] as! [[Double]]
            
            // 2D array of string and dictionary. pathData[0] is a dictionary of string:any
            let pathData: [[String:Any]] = dictionary["path_data"] as! [[String : Any]]
                        
            var coords = [currentLocation.coordinate]
            
            var totalDistance = 0.0
            var elevationGain = 0
            
            for node in path {
                
                let long = node[0]
                let lat = node[1]
                
                let curr = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                coords.append(curr)
                                
            }
            
            for nodeData in pathData {
                
                totalDistance += nodeData["length"] as! Double
                
            }
                        
            DispatchQueue.main.async {
                let polyline = MKPolyline(coordinates: coords, count: coords.count)
                self.mapView.addOverlay(polyline, level: .aboveRoads)
            
                let rect = polyline.boundingMapRect
                
                let newRect = MKMapRect(x: rect.minX - 50, y: rect.minY - 50, width: rect.width + 100, height: rect.height + 100)
                
                //self.mapView.setRegion(MKCoordinateRegion(newRect), animated: true)
                
                
                
                self.distanceLabel.text = String((totalDistance / 1000).rounded(toPlaces: 3)) + " km"
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
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

