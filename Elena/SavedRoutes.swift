//
//  SavedRoutes.swift
//  Elena
//
//  Created by Joe Pasquale on 11/15/20.
//

import UIKit
import MapKit
import CoreLocation

class SavedRoutes: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    
    func encode(with coder: NSCoder) {
                
        coder.encode(title, forKey: "title")
        coder.encode(addressString, forKey: "addressString")
    }
    
    required convenience init?(coder: NSCoder) {
        let title = coder.decodeObject(forKey: "title") as! String
        let address = coder.decodeObject(forKey: "addressString") as! String
        
        print(title, address)
        
        self.init(address: address)
        
    }
    
    
    //MARK: Properties
    var title: String! = ""
    var addressString: String! = ""
    var addressLocation: CLPlacemark!
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    init(address: String) {
        super.init()
        
        let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
 
                if (error != nil) {
                    return
                }
                let placemarks = placemarks!
                let placemark = placemarks.first!
                
                self.addressString = address
                self.addressLocation = placemark
                
                if placemark.areasOfInterest != nil && placemark.areasOfInterest!.count > 0 {
                    self.title = placemark.areasOfInterest![0]
                }
                
            }
        
    }
    
    //MARK: Initialization
    init(location: CLLocation!) {
        //title must not be empty
        super.init()
        
        if location == nil {
            return
        }
         
        getStreet(from: location!, completion: {
            placemarks, error in
            
            guard let placeMark = placemarks?.first else { return }
            
            
            // Full Address
            if let postalAddress = placeMark.postalAddress {
                let streets = postalAddress.street.split(separator: "–", maxSplits: 1, omittingEmptySubsequences: false)
                if streets.count > 1{
                    let removedHyphen = streets[1].split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
                    self.addressString = streets[0] + " " + removedHyphen[1] + ", " + postalAddress.city + ", " + postalAddress.state
                } else {
                    self.addressString = streets[0] + ", " + postalAddress.city + ", " + postalAddress.state
                }

            }
            self.addressLocation = placeMark
            
            if placeMark.areasOfInterest != nil && placeMark.areasOfInterest!.count > 0 {
                self.title = placeMark.areasOfInterest![0]
            }

            DispatchQueue.main.async {

                Settings.instance.savedRoutesList += [self]
    
                Settings.instance.saveRoutes()
    
                
            }
            
        })
        
    }
    
    func getStreet(from location: CLLocation, completion: @escaping (([CLPlacemark]?, Error?) -> ())) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error -> Void in
            completion(placemarks, error)
        })
    }
    
}
