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

protocol PropertyStoring {
    associatedtype T
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
}
extension PropertyStoring {
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
        guard let value = objc_getAssociatedObject(self, key) as? T else {
            return defaultValue
        }
        return value
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIView: PropertyStoring {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    typealias T = UIView
    private struct CustomProperties {
        static var toggleState = UIView()
    }
    
    var container: UIView {
        get {
            return getAssociatedObject(&CustomProperties.toggleState, defaultValue: CustomProperties.toggleState)
        }
        set {
            return objc_setAssociatedObject(self, &CustomProperties.toggleState, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func showActivityIndicatory() {
        if container != nil {
            container.removeFromSuperview()
        }
        container = UIView()
        container.frame = frame
        container.center = center
        
        var color: UIColor
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                color = UIColor(rgb: 0x000000)
            } else {
                color = UIColor(rgb: 0xffffff)
            }
        } else {
            color = UIColor(rgb: 0xffffff)
        }
        
        
        container.backgroundColor = color.withAlphaComponent(0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
        loadingView.center = center
        loadingView.backgroundColor = UIColor(rgb: 0x444444).withAlphaComponent(0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
        actInd.style =
            UIActivityIndicatorView.Style.large
        actInd.center = CGPoint(x:loadingView.frame.size.width / 2,
                                y:loadingView.frame.size.height / 2);
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        addSubview(container)
        actInd.startAnimating()
    }
}

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, UISearchBarDelegate{
    
    
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var savedRoutesButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bottomShelf: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var inclineLabel: UILabel!
    @IBOutlet weak var elevationGainLabel: UILabel!
    
    
    @IBOutlet weak var routeStatisticsLabel: UILabel!
    @IBOutlet weak var distanceTagLabel: UILabel!
    @IBOutlet weak var inclineTagLabel: UILabel!
    @IBOutlet weak var elevationTagLabel: UILabel!
    
    
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation!
    var destLocation: CLLocation!
    
    var destLoc = ""
    var startLoc = ""
    
    var firstCenter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                goButton.tintColor = .white
            } else {
                goButton.tintColor = .black
            }

        } else {
            // Fallback on earlier versions
        }
        
        //Initialize Settings
        Settings()
        
        // Make the buttons round
        settingsButton.layer.cornerRadius = settingsButton.frame.width / 2
        savedRoutesButton.layer.cornerRadius = savedRoutesButton.frame.width / 2
        
        // Make the bottom rounded
        bottomShelf.roundCorners(corners: [.topLeft, .topRight], radius: bottomShelf.frame.width / 10)
        
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
        
        searchField.delegate = self
        
        mapView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
           
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                goButton.tintColor = .white
            } else {
                goButton.tintColor = .black
            }

        } else {
            // Fallback on earlier versions
        }

        
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
        
        
        getStreet(from: destLocation, completion: {
            placemarks, error in
            
            guard let placeMark = placemarks?.first else { return }
            
            
            // Full Address
            if let postalAddress = placeMark.postalAddress {
                let streets = postalAddress.street.split(separator: "–", maxSplits: 1, omittingEmptySubsequences: false)
                print(postalAddress)
                if streets.count > 1{
                    let removedHyphen = streets[1].split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                    self.destLoc = streets[0] + " " + removedHyphen[1] + ", " + postalAddress.city + ", " + postalAddress.state
                } else {
                    self.destLoc = streets[0] + ", " + postalAddress.city + ", " + postalAddress.state
                }
                
                DispatchQueue.main.async {
                    self.displayPrelimDestination(dest: self.destLoc, placemark: placeMark)
                }
                
            }
            
            
            
            
        })
        
        
    }
    
    @IBAction func onSettingsTap(_ sender: UIButton) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    @IBAction func onSavedTap(_ sender: UIButton) {
        performSegue(withIdentifier: "toSavedRoutes", sender: self)
    }
    
    @IBAction func onGoTap(_ sender: UIButton) {
        
        self.view.showActivityIndicatory()
        
        mapView.removeOverlays(mapView.overlays)
        
        // Do validation check on destination
        destLoc = ""
        startLoc = ""
        
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
                    self.destLoc = streets[0] + " " + removedHyphen[1] + ", " + postalAddress.city + ", " + postalAddress.state
                } else {
                    self.destLoc = streets[0] + ", " + postalAddress.city + ", " + postalAddress.state
                }
                print(self.destLoc)
                
                if !self.startLoc.isEmpty {
                    self.sendToBackend(starting: self.startLoc, ending: self.destLoc)
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
                    self.startLoc = streets[0] + " " + removedHyphen[1] + ", " + postalAddress.city + ", " + postalAddress.state
                } else {
                    self.startLoc = streets[0] + ", " + postalAddress.city + ", " + postalAddress.state
                }
                print(self.startLoc)
                
                if !self.destLoc.isEmpty {
                    self.sendToBackend(starting: self.startLoc, ending: self.destLoc)
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
            "goal": Settings.instance.elevationGain,
            "limit": String(Settings.instance.tolerance),
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
                    DispatchQueue.main.async {
                        self.displayError(error.localizedDescription)
                    }
                }
            }
        }.resume()
        
    }
    
    func displayRoute(json: Any) {
        
        if let dictionary = json as? [String: Any] {
            
            if dictionary["path"] == nil {
                
                DispatchQueue.main.async {
                    self.displayError(dictionary["error"] as! String)
                }
                
                
                return
            }
            
            // 2D array of strings. path[0] is a [string] of ['long','lat']
            let path: [[Double]] = dictionary["path"] as! [[Double]]
            
            // 2D array of string and dictionary. pathData[0] is a dictionary of string:any
            let pathData: [[String:Any]] = dictionary["path_data"] as! [[String : Any]]
                        
            var coords = [currentLocation.coordinate]
            
            var totalDistance = 0.0
            var averageIncline = 0.0
            var elevationGain = 0.0
            
            for i in 0...path.count - 1 {
                
                let node = path[i]
                let nodeData = pathData[i]
                
                let long = node[0]
                let lat = node[1]
                
                let curr = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                coords.append(curr)
                
                totalDistance += nodeData["length"] as! Double
                
                if i != path.count - 1 {
                    averageIncline += nodeData["grade"] as! Double
                    if ((pathData[i+1]["elevation"] as! Double) - (nodeData["elevation"] as! Double) > 0) {
                        elevationGain += (pathData[i+1]["elevation"] as! Double) - (nodeData["elevation"] as! Double)
                    }
                }
                                
            }
            
            averageIncline /= Double(path.count)
                        
            DispatchQueue.main.async {
                let polyline = MKPolyline(coordinates: coords, count: coords.count)
                self.mapView.addOverlay(polyline, level: .aboveRoads)
            
                let rect = polyline.boundingMapRect
                
                let newRect = MKMapRect(x: rect.minX - 50, y: rect.minY - 50, width: rect.width + 100, height: rect.height + 100)
                
                //self.mapView.setRegion(MKCoordinateRegion(newRect), animated: true)
                
                
                
                self.distanceLabel.text = String((totalDistance / 1000).rounded(toPlaces: 3)) + " km"
                self.inclineLabel.text = String((averageIncline * 10).rounded(toPlaces: 3)) + " meters per 10 meters"
                self.elevationGainLabel.text = String(elevationGain) + " m"
                
                self.distanceTagLabel.text = "Distance"
                self.inclineTagLabel.text = "Incline"
                self.elevationTagLabel.text = "Elevation Gain"
                
                self.routeStatisticsLabel.text = "Route to " + self.destLoc
                
                self.view.container.removeFromSuperview()
            }
        }
        
    }
    
    
    func displayPrelimDestination(dest: String, placemark: CLPlacemark) {
        
        self.distanceLabel.isUserInteractionEnabled = false
        self.inclineLabel.isUserInteractionEnabled = false
        self.elevationGainLabel.isUserInteractionEnabled = false
        
        self.distanceLabel.text = " "
        self.inclineLabel.text = " "
        self.elevationGainLabel.text = " "
        
        self.distanceTagLabel.text = " "
        self.inclineTagLabel.text = " "
        self.elevationTagLabel.text = " "
        
        if (placemark.areasOfInterest != nil && placemark.areasOfInterest!.count > 0) {
            self.routeStatisticsLabel.text = placemark.areasOfInterest![0]
            inclineLabel.text = dest
        } else {
            self.routeStatisticsLabel.text = dest
        }
        
        
        
    }
    
    func displayError(_ error: String) {
        self.distanceLabel.isUserInteractionEnabled = false
        self.inclineLabel.isUserInteractionEnabled = false
        self.elevationGainLabel.isUserInteractionEnabled = false
        
        self.distanceLabel.text = " "
        self.inclineLabel.text = error
        self.elevationGainLabel.text = " "
        
        self.distanceTagLabel.text = " "
        self.inclineTagLabel.text = " "
        self.elevationTagLabel.text = " "
        
        self.routeStatisticsLabel.text = "Sorry :/"
        
        self.view.container.removeFromSuperview()
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
        if !firstCenter {
            mapView.centerToLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
            firstCenter = true
        }
        
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var bottomConst:NSLayoutConstraint? = nil
            for const in self.view.constraints {
                if (const.identifier == "Bottom") {
                    bottomConst = const
                    break
                }
            }
            
            if bottomConst != nil {
                bottomConst?.constant = -keyboardSize.height
            }
            
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        var bottomConst:NSLayoutConstraint? = nil
        for const in self.view.constraints {
            if (const.identifier == "Bottom") {
                bottomConst = const
                break
            }
        }
        
        if bottomConst != nil {
            bottomConst?.constant = 0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.routeStatisticsLabel.text = "Search Results"
        
        self.distanceLabel.text = " "
        self.inclineLabel.text = " "
        self.elevationGainLabel.text = " "
        
        self.distanceTagLabel.text = " "
        self.inclineTagLabel.text = " "
        self.elevationTagLabel.text = " "
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            
            var count = response.mapItems.count
            count = count > 3 ? 3 : count
            
            
            
            print(count)
            
            for i in 0...count - 1 {
                
                let item = response.mapItems[i]
                print(item)
                if i == 0 {
                    self.distanceLabel.text = item.name
                    let rec = SearchTapGesture(target: self, action: #selector(self.onSearchTap(_:)))
                    rec.item = item
                    self.distanceLabel.isUserInteractionEnabled = true
                    self.distanceLabel.addGestureRecognizer(rec)
                }
                if i == 1 {
                    self.inclineLabel.text = item.name
                    let rec = SearchTapGesture(target: self, action: #selector(self.onSearchTap(_:)))
                    rec.item = item
                    self.inclineLabel.isUserInteractionEnabled = true
                    self.inclineLabel.addGestureRecognizer(rec)
                }
                if i == 2 {
                    self.elevationGainLabel.text = item.name
                    let rec = SearchTapGesture(target: self, action: #selector(self.onSearchTap(_:)))
                    rec.item = item
                    self.elevationGainLabel.isUserInteractionEnabled = true
                    self.elevationGainLabel.addGestureRecognizer(rec)
                }
                
            }
            
        }
        
    }
    
    class SearchTapGesture: UITapGestureRecognizer {
        var item: MKMapItem!
    }
    
    @objc func onSearchTap(_ sender: SearchTapGesture) {
        
        let item = sender.item!
        
        let coordinate = item.placemark.coordinate
        let placeMark = item.placemark
        
        destLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        mapView.removeAnnotations(mapView.annotations)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        
            // Full Address
            if let postalAddress = placeMark.postalAddress {
                let streets = postalAddress.street.split(separator: "–", maxSplits: 1, omittingEmptySubsequences: false)
                print(postalAddress)
                if streets.count > 1{
                    let removedHyphen = streets[1].split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                    self.destLoc = streets[0] + " " + removedHyphen[1] + ", " + postalAddress.city + ", " + postalAddress.state
                } else {
                    self.destLoc = streets[0] + ", " + postalAddress.city + ", " + postalAddress.state
                }
                
                DispatchQueue.main.async {
                    self.displayPrelimDestination(dest: self.destLoc, placemark: placeMark)
                }
                
            }
 
        
    }
}

