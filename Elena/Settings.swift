//
//  Settings.swift
//  Elena
//
//  Created by Maxwell Hubbard on 11/15/20.
//

import Foundation

class Settings {
    
    public static var instance: Settings!
    
    public var tolerance: Int = 120
    public var units: Bool = false //km = false, miles = true
    public var elevationGain: String = "Maximize Elevation Gain"
    
    init () {
        Settings.instance = self
    }
    
    
    
}
