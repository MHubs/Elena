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
    var addressLocation: Int
    
    //MARK: Initialization
    init?(title: String, addressString: String, addressLocation: Int) {
        //title must not be empty
        guard !title.isEmpty else{
            return nil
        }
        //address string must not be empty
        guard !addressString.isEmpty else{
            return nil
        }
        self.title = title
        self.addressString = addressString
        self.addressLocation = addressLocation
    }
    
    
}
