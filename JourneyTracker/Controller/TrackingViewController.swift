//
//  FirstViewController.swift
//  JourneyTracker
//
//  Created by Arunprasat Selvaraj on 15/07/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TrackingViewController: BaseViewController {
    
    private var trackViewModel: TrackingViewModel!
    private var locationManager = CLLocationManager()
    private var sourceLocation = CLLocationCoordinate2D()
    private var pointAnnotation = [MKPointAnnotation]()
    private var drawingTimer: Timer?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        bindValues()
    }
    
    func initialSetup() {
        
        //1.
        // locationManager setup
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        //2.
        //Setup mapview
        self.mapView.showsUserLocation = true
        self.mapView.isZoomEnabled = true
        self.mapView.showsCompass = true
        self.mapView.layoutMargins = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        self.mapView.delegate = self
        
        //3.
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            
            self.sourceLocation = CLLocationCoordinate2D.init(latitude: 51.5079, longitude: 0.1378)
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(viewRegion, animated: false)
        }
        
    }
    func bindValues() {
        
        trackViewModel = TrackingViewModel()
        
        trackViewModel.reloadDataBlock = {
            
            if let polyline = self.trackViewModel.polyline {
                //5.
                //Passing the values to update the map with places and route
                self.drawRoutesandAddAnnotations(pointAnnotation: self.pointAnnotation, polyline: polyline)
            }
        }
    }
    
//    func animate(route: [CLLocationCoordinate2D], duration: TimeInterval, completion: (() -> Void)?) {
//        guard route.count > 0 else { return }
//        var currentStep = 1
//        let totalSteps = route.count
//        let stepDrawDuration = duration/TimeInterval(totalSteps)
//        var previousSegment: MKPolyline?
//
//        drawingTimer = Timer.scheduledTimer(withTimeInterval: stepDrawDuration, repeats: true) { [weak self] timer in
//            guard let self = self else {
//                // Invalidate animation if we can't retain self
//                timer.invalidate()
//                completion?()
//                return
//            }
//
//            if let previous = previousSegment {
//                // Remove last drawn segment if needed.
//                self.mapView.removeOverlay(previous)
//                previousSegment = nil
//            }
//
//            guard currentStep < totalSteps else {
//                // If this is the last animation step...
//                let finalPolyline = MKPolyline(coordinates: route, count: route.count)
//                self.mapView.addOverlay(finalPolyline)
//                // Assign the final polyline instance to the class property.
//                //  self.polyline = finalPolyline
//                timer.invalidate()
//                completion?()
//                return
//            }
//
//            // Animation step.
//            // The current segment to draw consists of a coordinate array from 0 to the 'currentStep' taken from the route.
//            let subCoordinates = Array(route.prefix(upTo: currentStep))
//            let currentSegment = MKPolyline(coordinates: subCoordinates, count: subCoordinates.count)
//            self.mapView.addOverlay(currentSegment)
//
//            previousSegment = currentSegment
//            currentStep += 1
//        }
//    }
    
    func drawRoutesandAddAnnotations(pointAnnotation: [MKPointAnnotation]?, polyline: MKPolyline) {
        
        //1.
        //Removing the last annotations
        self.mapView.removeAnnotations(self.mapView.annotations.dropLast())
        
        //2.
        //Removing the overlays
        self.mapView.removeOverlays(self.mapView.overlays)
        
        //3.
        //Add the placemark to the map view if it present
        if let pointAnnotation = pointAnnotation {
            self.mapView.addAnnotations(pointAnnotation)
        }
        
        
        //4.
        //Add the polyline to the map view if it present
        self.mapView.addOverlay((polyline), level: MKOverlayLevel.aboveRoads)
        
        //5.
        //Make the annotations to visible in the screen if it present
        self.mapView.setRegion(MKCoordinateRegion(polyline.boundingMapRect), animated: true)
    }
}

extension TrackingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //1.
        //Getting the current location
        let location: CLLocation = locations[0] as CLLocation
        
        //2.
        //Get the placemarks and save it variable
        self.pointAnnotation = trackViewModel.getAnnotationsFromCoordinates(source: sourceLocation, destination: location.coordinate)
        
        //3.
        //Passing the location to the view model and it returns the map items
        let items = trackViewModel.getMapItemsFromCoordinates(source: sourceLocation, destination: location.coordinate)
        
        //4.
        //Returns the polyline direction between 2 mapitem in reloadDataBlock
        self.trackViewModel.getDirectionBetweenTheMapItems(sourceMapItem: items.source, destinationMapItem: items.destination)
    }
}

extension TrackingViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 2.5
            
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
}
