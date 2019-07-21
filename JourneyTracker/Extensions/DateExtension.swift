//
//  DateExtension.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 20/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func convertDateFormater() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"//1977-05-25T07:00:00Z
        dateFormatter.dateFormat = Constants.AppDateFormate.appDateFormate
        
        return  dateFormatter.string(from: self)
    }
}
