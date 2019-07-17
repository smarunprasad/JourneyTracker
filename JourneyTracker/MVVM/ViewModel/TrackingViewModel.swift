//
//  TrackingViewModel.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 17/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class TrackingViewModel {
    
    var reloadDataBlock: (() -> Void) = {
        
    }
    
    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    var sourceLocation = CLLocationCoordinate2D()
    var finalLocation = CLLocationCoordinate2D()
    
    
    func setuplocationManager() -> CLLocationManager {
        
        //1.
        // locationManager setup
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        //2.
        //Setting the current location as Source location in variable sourceLocation
        if let location = locationManager.location?.coordinate {
            
            //3.
            sourceLocation = location
            //Adding the location to this variable to use at next time
            finalLocation = location
        }
        
        return locationManager
    }
    
    func setupMapView() -> MKMapView {
        
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.centerCoordinate = sourceLocation
        return mapView
    }
    
    func addLocationandDrawRout(location: CLLocationCoordinate2D) -> (annotations: [MKPointAnnotation], polyline: MKPolyline, mapRect: MKMapRect) {
        
        // 1.
        //Adding the Source location to MKPlacemark
        let sourcePlacemark = MKPlacemark(coordinate: finalLocation)
        
        // 2.
        //Adding the sourcePlacemark in the MKMapItem
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // 3.
        //Adding the destination Map item to MKPointAnnotation
        let sourceAnnotation = MKPointAnnotation()
        if let location = sourcePlacemark.location {
            
            //Setting the coordinate in sourceAnnotation
            sourceAnnotation.coordinate = location.coordinate
        }
        
        // 4.
        //Adding the current location received from the location manager delegate to MKPlacemark
        let destinationPlacemark = MKPlacemark(coordinate: location)
        
        //5.
        //Adding the destinationPlacemark in the MKMapItem
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 6.
        //Adding the destination Map item to MKPointAnnotation
        let destinationAnnotation = MKPointAnnotation()
        if let location = destinationPlacemark.location {
            //Setting the coordinate in destinationAnnotation
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // 7.
        //Adding the MKDirections with source & destination
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        //8.
        // Calculate the direction using directionRequest
        let directions = MKDirections(request: directionRequest)
        var route = MKRoute()
        
        // 9.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            //10.
            //Adding the routes from the responce to the MKRoute
            route = response.routes[0]
        }
        
        //11.
        //Adding the location to this variable to use at next time
        finalLocation = destinationAnnotation.coordinate
        
        //12.
        //Returning the values to controller to update the map view
        return ([sourceAnnotation, destinationAnnotation], route.polyline, route.polyline.boundingMapRect)
    }
    
    func saveLocationInKeyChain(location: CLLocationCoordinate2D) {
        
    }
}

