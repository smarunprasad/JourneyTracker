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

class TrackingViewModel {
    
    var reloadDataBlock: (() -> Void) = {
        
    }
    var polyline: MKPolyline?
    private var drawingTimer: Timer?

    
    func getAnnotationsFromCoordinates(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) ->
        [MKPointAnnotation] {
            
            // 1.
            //Adding the Source location to MKPointAnnotation
            let sourcePoint = MKPointAnnotation()
            sourcePoint.coordinate  = source
            sourcePoint.title = Constants.Keys.source

            // 2.
            //Adding the current location received from the location manager delegate to MKPointAnnotation
            let destinationPoint = MKPointAnnotation()
            destinationPoint.coordinate  = destination
            destinationPoint.title = Constants.Keys.destination

            //3.
            //Returns the source & destination points
            return [sourcePoint, destinationPoint]
    }
    
    func getMapItemsFromCoordinates(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) ->
        (source: MKMapItem?, destination: MKMapItem?) {
            
            // 1.
            //Adding the Source location to MKPlacemark
            let sourcePlacemark = MKPlacemark(coordinate: source)
            
            // 2.
            //Adding the sourcePlacemark in the MKMapItem
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            
            // 3.
            //Adding the current location received from the location manager delegate to MKPlacemark
            let destinationPlacemark = MKPlacemark(coordinate: destination)
            
            //4.
            //Adding the destinationPlacemark in the MKMapItem
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
           
            //5.
            //Returns the map items
            return (sourceMapItem, destinationMapItem)
    }
    
    
    func getDirectionBetweenTheMapItems(sourceMapItem: MKMapItem?, destinationMapItem: MKMapItem?) {
        
        // 1.
        //Adding the MKDirections with source & destination
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        print(directionRequest.transportType)
        //2.
        // Calculate the direction using directionRequest
        let directions = MKDirections(request: directionRequest)
       // var polyline: MKPolyline?
        
        // 3.
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
            
            //6.
            //Returning the polyline to controller to update the map view
            self.reloadDataBlock()
        }
    }
    
//    func animate(route: [CLLocationCoordinate2D], duration: TimeInterval, completion: (() -> Void)?) {
////        guard route.count > 0 else { return }
////        var currentStep = 1
////        let totalSteps = route.count
////        let stepDrawDuration = duration/TimeInterval(totalSteps)
////        var previousSegment: MKPolyline?
////
////        drawingTimer = Timer.scheduledTimer(withTimeInterval: stepDrawDuration, repeats: true) { [weak self] timer in
////            guard let self = self else {
////                // Invalidate animation if we can't retain self
////                timer.invalidate()
////                completion?()
////                return
////            }
////
////            if let previous = previousSegment {
////                // Remove last drawn segment if needed.
////                self.mapView.removeOverlay(previous)
////                previousSegment = nil
////            }
////
////            guard currentStep < totalSteps else {
////                // If this is the last animation step...
////                let finalPolyline = MKPolyline(coordinates: route, count: route.count)
////                self.mapView.addOverlay(finalPolyline)
////                // Assign the final polyline instance to the class property.
////                self.polyline = finalPolyline
////                timer.invalidate()
////                completion?()
////                return
////            }
////
////            // Animation step.
////            // The current segment to draw consists of a coordinate array from 0 to the 'currentStep' taken from the route.
////            let subCoordinates = Array(route.prefix(upTo: currentStep))
////            let currentSegment = MKPolyline(coordinates: subCoordinates, count: subCoordinates.count)
////            self.mapView.addOverlay(currentSegment)
////
////            previousSegment = currentSegment
////            currentStep += 1
////        }
//    }
    func saveLocationInKeyChain(location: CLLocationCoordinate2D) {
        
    }
}

