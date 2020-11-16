//
//  DefaultData.swift
//  Elena
//
//  Created by Maxwell Hubbard on 11/15/20.
//

import Foundation

class DefaultData {

    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func saveValue(forKey key: String, value: Any) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    public func getValue(forKey key: String) -> Any? {
        return userDefaults.value(forKey: key)
    }
    
    public func getData(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
}
