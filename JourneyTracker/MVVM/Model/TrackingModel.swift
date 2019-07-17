//
//  TrackingModel.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 17/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation

struct TrackingModel {
    
    var journeyId: Int!
    var duration: String?
    var StartDate: String?
    var endDate: String?
    var fromLocation: Double!
    var toLocation: [Double]!
}
