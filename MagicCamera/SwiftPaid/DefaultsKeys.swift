//
//  Data.swift
//  MagicCamera
//
//  Created by William on 2020/12/23.
//

import Foundation

struct DefaultsKeys {
    static var IsPaid = true
    
    static var allFilters: [MTFilter.Type] = []
    static var cachedFilters: [Int: MTFilter] = [:]
    static var cachedTry: [String: Bool] = [:]
    
    static func InitFilters() {
        allFilters = MTFilterManager.shared.allFilters
        for index in 0..<allFilters.count {
            let filter = allFilters[index].init()
            cachedFilters[index] = filter
        }
    }
    
    static func getFilterAtIndex(_ index: Int) -> MTFilter {
        if let filter = cachedFilters[index] {
            return filter
        }
        let filter = allFilters[index].init()
        cachedFilters[index] = filter
        return filter
    }
    
    static func LoadConfig() {
        loadFxTry(name: "fleeting")
        loadFxTry(name: "hdr")
        loadFxTry(name: "kuwahara")
        loadFxTry(name: "pixellate")
        loadFxTry(name: "toon")
        loadFxTry(name: "lomo")
    }

    static func CanFxUse(name:String) -> Bool {
        if IsPaid {
            return true
        }
        if let tryItem = cachedTry[name] {
            return !tryItem
        }
        return false
    }
    
    static func IsFxTry(name:String) -> Bool {
        if IsPaid {
            return true
        }
        if let tryItem = cachedTry[name] {
            return tryItem
        }
        return false
    }
    
    static func loadFxTry(name:String) {
        let defaults = UserDefaults.standard
        let tryItem = defaults.bool(forKey: "IsTry_" + name)
        cachedTry[name] = tryItem
        return
    }
    
    static func SetFxTry(name:String) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "IsTry_" + name)
        cachedTry[name] = true
    }
    

}
