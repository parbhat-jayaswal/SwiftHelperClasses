//
//  LocalUserDefault.swift
//  SwiftHelperClasses
//
//  Created by Prabhat on 20/07/20.
//  Copyright © 2020 Parbhat. All rights reserved.
//

import Foundation

func saveDict(info: [String: Any], key: String) {
    if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: info, requiringSecureCoding: false) {
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: key)
    }
}

func loadDict(key: String) -> [String: Any] {
    let defaults = UserDefaults.standard
    if let savedPeople = defaults.object(forKey: key) as? Data {
        if let decodedInfo = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [String: Any] {
            return decodedInfo
        }
    }
    
    return [:]
}


func saveString(info: String, key: String) {
    UserDefaults.standard.set(info, forKey: key)
}

func getSting(key: String) -> [String: Any] {
    if let info = UserDefaults.standard.value(forKey: key) as? [String : Any] {
        return info
    }
    return [:]
}
