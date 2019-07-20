//
//  TrackingModel.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 17/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import CoreLocation

struct TrackingModel: Codable {
    
    var journeyId: Int!
    var duration: Int?
    var StartDate: Date!
    var endDate: Date?
    var source: String?
    var destination: String?
    var sourceLat: Float!
    var sourceLong: Float!
    var travelledPoints: [TravelledPoint]!
    
    init(journeyId: Int!, duration: Int?, StartDate: Date!, endDate: Date?, source: String, destination: String?, sourceLat: Float!, sourceLong: Float!, travelledPoints: [TravelledPoint]!) {
        self.journeyId = journeyId
        self.duration = duration
        self.StartDate = StartDate
        self.endDate = endDate
        self.source = source
        self.destination = destination
        self.sourceLat = sourceLat
        self.sourceLong = sourceLong
        self.travelledPoints = travelledPoints
    }
}

struct TravelledPoint: Codable {
    
    var Latitude: Float!
    var longitude: Float!
}
