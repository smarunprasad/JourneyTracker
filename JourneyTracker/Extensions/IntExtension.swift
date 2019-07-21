//
//  TimeIntervalExtension.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 19/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation

extension Int {
    
    func stringFromTimeInterval() -> String? {
                
        let minutes = self % 60
        let hours = (self / 60) % 60
        var aString = ""
        
        if hours == 0 && minutes == 0 {
            return ""
        }
        else if hours == 0 {
            aString = String(format: "%0.2d min",minutes)
        }
        else if minutes == 0 {
            aString = String(format: "%0.2d hrs",hours)
        }
        else {
            aString = String(format: "%0.2d hrs %0.2d min",hours,minutes)
        }
        
        return aString
    }
}
