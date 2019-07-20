//
//  KeychainManager.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 20/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class KeychainManager {
    
    static func setIsTrackingStatusToWapper(isTracking: Bool) {
        
        //Saving the bool in the keychain wrapper it returns the bool value
        let value = KeychainWrapper.standard.set(isTracking, forKey: Constants.KeyChain.isTracking)
        
    }
    
    static func getIsTrackingStatusFromWapper() -> Bool {
        
        //getting the bool value from the keychain
        let value: Bool = KeychainWrapper.standard.bool(forKey: Constants.KeyChain.isTracking) ?? false
        return value

    }
    static func setDataToWapper(data: Data) -> Bool {
        
        //1.
        //delete the previous data and add the new one
        removeWapperForKey(key: Constants.KeyChain.journey)
        
        //2.
        //Saving the data in the keychain wrapper it returns the bool value
        let aBool = KeychainWrapper.standard.set(data, forKey: Constants.KeyChain.journey)
        
        //3. return bool value of the status
        return aBool
    }

    static func getALLDataFromWapper<M: Codable>() -> [M] {
        
        //getting the data from the keychain
        let value = KeychainWrapper.standard.data(forKey: Constants.KeyChain.journey)
        
        guard let data = value else {
            return [M]()
        }
        
        do {
            let object = try JSONDecoder().decode([M].self, from: data)
            return object
        }
        catch {
            return [M]()
        }
    }
    
    static func getCurrentDataFromWapper<M: Codable>(journeyId: Int) -> M? {
        
        //getting the data from the keychain
        let value = KeychainWrapper.standard.data(forKey: Constants.AppName.appName)
        
        guard let data = value else {
            return nil
        }
        
        do {
            let object = try JSONDecoder().decode(M.self, from: data)
            return object
        }
        catch {
            return nil
        }
    }
    
    static func removeWapperForKey(key: String) {
        
        let _ = KeychainWrapper.standard.removeObject(forKey: key)
    }
}
