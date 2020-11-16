//
//  Settings.swift
//  Elena
//
//  Created by Maxwell Hubbard on 11/15/20.
//

import Foundation

class Settings {
    
    public static var instance: Settings!
    let defData: DefaultData = DefaultData()
    
    public var tolerance: Int = 120
    public var units: Bool = false //km = false, miles = true
    public var elevationGain: String = "Maximize Elevation Gain"
    public var savedRoutesList = [SavedRoutes]()
    
    init () {
        Settings.instance = self
        loadSavedRoutes()
    }
    
    func loadSavedRoutes() {
        
        if defData.getValue(forKey: "savedRoutes") == nil {
            
            Settings.instance.savedRoutesList = []
            saveRoutes()
            return
        }
        
        let decoded = defData.getData(forKey: "savedRoutes")
                
        if (decoded != nil) {
            do {
                Settings.instance.savedRoutesList = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: SavedRoutes.self, from: decoded!)!
            } catch {
                print(error)
            }
            
        } else {
            Settings.instance.savedRoutesList = []
            saveRoutes()
        }
        
        
    }
    
    func saveRoutes() {
        
        do {
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: savedRoutesList, requiringSecureCoding: false)
            
            defData.saveValue(forKey: "savedRoutes", value: encodedData)
        } catch {
            
        }
        
        
    }
    
}
