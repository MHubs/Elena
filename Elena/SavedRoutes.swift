//
//  SavedRoutes.swift
//  Elena
//
//  Created by Joe Pasquale on 11/15/20.
//

import UIKit
import MapKit
import CoreLocation

class SavedRoutes {
    
    //MARK: Properties
    var title: String
    var addressString: String
    var addressLocation: MKPlacemark?
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    //MARK: Initialization
    init?(title: String, addressString: String) {
        //title must not be empty
        guard !title.isEmpty else{
            return nil
        }
        self.title = title
        self.addressString = addressString
        self.addressLocation = geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                return
            }

            // Use your location
        }
    }
    
}
