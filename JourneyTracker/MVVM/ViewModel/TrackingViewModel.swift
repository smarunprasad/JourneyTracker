//
//  TrackingViewModel.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 17/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import SwiftKeychainWrapper

class TrackingViewModel {
    
    var reloadDataBlock: (() -> Void) = {
        
    }
    
    var switchStatChanged: ((Bool) -> Void) = { aBool in
        
    }
    
    var polyline: MKPolyline?
    var sourceLocation = CLLocation()
    var pointAnnotation = [MKPointAnnotation]()
    var trackingModel: TrackingModel!
    var isForTracking: Bool!
    var isTracking: Bool!
    
    private var lastJourneyId = 0
    private var allJourney: [TrackingModel] =  [TrackingModel]()
    private var startLocation = CLLocation()
    private var locationManager = CLLocationManager()
    private var duration: Int?
    private var startDate: Date!
    private var endDate: Date?
    var source: String?
    private var destination: String?
    private var sourcePoint: CLLocationCoordinate2D!
    private var travelledPoints = [TravelledPoint]()
    
    //MARK:- MapView Helper
    func setupMapViewWithLocation(location: CLLocation) {
        
        //1.
        self.startLocation = self.sourceLocation
        
        //2.
        //Get the placemarks and save it variable
        if self.pointAnnotation.isEmpty == true {
            
            //3.
            //Returns the point for given location
            if let annotation = getAnnotationsFromCoordinate(source: self.startLocation.coordinate) {
                
                //4.
                //Add the value to the array and setting the location title
                annotation.title = Constants.Keys.source
                self.pointAnnotation = [MKPointAnnotation]()
                self.pointAnnotation.append(annotation)
            }
        }
        
        //5.
        //Getting the current location point
        if let annotation = getAnnotationsFromCoordinate(source: location.coordinate) {
            
            //6.
            //Add the value to the array and setting the annotation title
            annotation.title = Constants.Keys.destination
            
            //7.
            //Remove the last object from array and add the current annotation to an array
            if self.pointAnnotation.count > 1 { self.pointAnnotation = self.pointAnnotation.dropLast() }
            self.pointAnnotation.append(annotation)
        }
        
        //8.
        //Passing the location to the view model and it returns the map items
        let items = getMapItemsFromCoordinates(source: self.startLocation, destination: location)
        
        //9.
        //Update the startLocation with destination location
        self.startLocation = location
        
        //10.
        //Returns the polyline direction between 2 mapitem in reloadDataBlock
        getDirectionBetweenTheMapItems(sourceMapItem: items.source, destinationMapItem: items.destination)
        
        //check is the map appear for tracking or appear for view
        if isForTracking == true {
            
            if self.source == nil {
                //11.
                //Setting the source location in the model
                getPlacedetailsFromLocation(location: self.sourceLocation)
            }
            //12.
            //Setting the destination location in the model
            getPlacedetailsFromLocation(location: location)
        }
    }
    
    func getAnnotationsFromCoordinate(source: CLLocationCoordinate2D) ->
        MKPointAnnotation? {
            
            //1.
            //Adding the Source location to MKPointAnnotation
            let PointAnnotation = MKPointAnnotation()
            PointAnnotation.coordinate  = source
            
            //2.
            //Returns the MKPointAnnotation
            return PointAnnotation
    }
    
    func getMapItemsFromCoordinates(source: CLLocation, destination: CLLocation) ->
        (source: MKMapItem?, destination: MKMapItem?) {
            
            //1.
            //Returns the MKPlacemark of the Source location
            let sourcePlacemark = MKPlacemark.init(coordinate: source.coordinate)
            
            //2.
            //Adding the sourcePlacemark in the MKMapItem
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            
            //3.
            //Adding the current location received from the location manager delegate to MKPlacemark
            let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate)
            
            //4.
            //Adding the destinationPlacemark in the MKMapItem
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            //5.
            //Returns the map items
            return (sourceMapItem, destinationMapItem)
    }
    
    func getDirectionBetweenTheMapItems(sourceMapItem: MKMapItem?, destinationMapItem: MKMapItem?) {
        
        //1.
        //Adding the MKDirections with source & destination
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        //2.
        // Calculate the direction using directionRequest
        let directions = MKDirections(request: directionRequest)
        var isCalculated = false
        //3.
        //Direction Request
        directions.calculate { (response, error) in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            //4.
            //Getting the routes from the responce to the MKRoute
            var route = MKRoute()
            route = response.routes[0]
            
            //5.
            //Add the polyline to the variable
            self.polyline = route.polyline
            isCalculated = true
            //6.
            //Returning the polyline to controller to update the map view
            self.reloadDataBlock()
        }
        
        if isCalculated {
            //6.
            //Returning the polyline to controller to update the map view
            self.reloadDataBlock()
        }
    }
    
    func setupJouneyPoints(trackingModel: TrackingModel) {
        
        //Returns the location from the Double values
        let location = CLLocation.getLocationFrom(lat: trackingModel.sourceLat, long: trackingModel.sourceLong)
        
        //1.
        //Passing the location to setup the annotations & polyline
        setupMapViewWithLocation(location: location)
        
        //2.
        //Passing the travelledPoints
        for travelledPoint in trackingModel.travelledPoints {
            
            //Returns the location from the Double values
            let location = CLLocation.getLocationFrom(lat: travelledPoint.Latitude, long: travelledPoint.longitude)
            
            //3.
            //Passing the location to setup the annotations & polyline
            setupMapViewWithLocation(location: location)
        }
    }
    
    
    //MARK:- Switch Actiopn Helper
    func switchValueChanged(state: Bool) {
        
        isTracking = state
        
        if state == false {
            
            if self.source != nil && destination != nil {
                //Save all the value in the model
                saveValueInModel()
            }
        }
        
        //Adding the value in the keychain
        KeychainManager.setIsTrackingStatusToWapper(isTracking: state)
        
        //update the map view 
        self.switchStatChanged(state)
    }
    
    //MARK:- Save value in model & keychain Helper
    func getPlacedetailsFromLocation(location: CLLocation) {
        
        self.locationManager.getPlace(for: location) { placemark in
            
            //Checking for the placemark
            guard let placemark = placemark else { return }
            
            //1.
            //Checking for the sublocality
            guard let subLocality = placemark.subLocality else {
                
                //1.
                //Checking for the locality
                guard let locality = placemark.locality else {
                    
                    //1.
                    //Checking for the thoroughfare
                    guard let thoroughfare = placemark.thoroughfare else { return }
                    //2.
                    //Passing the thoroughfare to save the values
                    self.addSourceandDestination(value: thoroughfare)
                    return
                }
                
                //2.
                //Passing the locality to save the values
                self.addSourceandDestination(value: locality)
                return
            }
            //2.
            //Passing the sublocality to save the values
            self.addSourceandDestination(value: subLocality)
            
            //3.
            //adding the location
            self.addSourceandDestinationLocation(location: location)
        }
    }
    
    func addSourceandDestination(value: String?) {
        //1.
        //If source is nil then add it to the source variable
        if self.source == nil {
            //2.
            //Adding Values
            self.source = value
            //Set the current date to display it in the journey list
            self.startDate = Date()
        }
        else {
            //3.
            //Adding Values
            self.destination = value
        }
    }
    
    func addSourceandDestinationLocation(location: CLLocation) {
        
        //1.
        //If source is nil then add it to the source variable
        if self.sourcePoint == nil {
            //2.
            //Adding Values
            self.sourcePoint = location.coordinate
            //Set the current date to display it in the journey list
            self.startDate = Date()
        }
        else {
            //3.
            //Adding coordinates to the TravelledPoint model
            let travelledPoint = TravelledPoint.init(Latitude: Float(location.coordinate.latitude), longitude: Float(location.coordinate.longitude))
            //4.
            //Append the value to the array
            self.travelledPoints.append(travelledPoint)
            
            //5.
            //Save all the value in the model
            self.saveValueInModel()
        }
    }
    
    func getDurationOfTravel() {
        
        //Creating the calender
        let calendar = Calendar.current
        //Returns the date components between 2 dates
        let datecomponenets = calendar.dateComponents([.second], from: startDate, to: endDate!)
        //save the difference in the variable
        self.duration = datecomponenets.second
    }
    
    func setLastJourneyIdandGetAllJourney() {
        
        //1.
        allJourney = [TrackingModel]()
        
        //2.
        //Get all values from the keychain
        allJourney = KeychainManager.getALLDataFromWapper()
    }
    
    func saveValueInModel() {
        
        //1.
        //Setting end date
        self.endDate = Date()
        
        //2.
        //Get travel time using start date & end date
        getDurationOfTravel()
        
        //3.
        //Get the last journey id and all journey list
        setLastJourneyIdandGetAllJourney()
        
        //4.
        //checking the array contains the value
        //Getting the last object to update the the journey id in keychain
        //Checking is there any tracking is in progress
        if allJourney.isEmpty == false, let journey = allJourney.last {
            
            if isTracking == true {
                
                isTracking = false
                //5.
                //Update the value to the journeyID
                self.lastJourneyId = journey.journeyId + 1
            }
            else {
                //Using the same id for the current journey
                self.lastJourneyId = journey.journeyId
            }
        }
        else {
            if isTracking == true {
                isTracking = !isTracking
            }
        }
        //6.
        //Filter the array
        allJourney = allJourney.filter({ $0.journeyId !=  self.lastJourneyId  })
        
        //7.
        //Adding the values in the model
        self.trackingModel = TrackingModel.init(journeyId: self.lastJourneyId, duration: duration, StartDate: startDate, endDate: endDate, source: source!, destination: destination!, sourceLat: Float(sourcePoint.latitude), sourceLong: Float(sourcePoint.longitude), travelledPoints: travelledPoints)
        
        //8.
        //Adding the current value to the variable
        allJourney.append(self.trackingModel)
        print("count - \(allJourney.count)")
        
        do {
            
            //9.
            //Converting the model to data
            let data = try JSONEncoder().encode(allJourney)
            
            //10.
            //Passing the data to KeychainManager
            let isSuccess = KeychainManager.setDataToWapper(data: data)
            print(isSuccess)
        }
        catch {
            print(error)
        }
    }
}
