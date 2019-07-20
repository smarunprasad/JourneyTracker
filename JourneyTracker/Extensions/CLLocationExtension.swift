//
//  CLLocationExtension.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 20/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    
    static func getLocationFrom(lat: Float, long: Float) -> CLLocation {
        
        return CLLocation.init(latitude: CLLocationDegrees.init(lat), longitude: CLLocationDegrees.init(long))
    }
}
