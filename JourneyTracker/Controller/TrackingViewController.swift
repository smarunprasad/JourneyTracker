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

    var trackViewModel: TrackingViewModel!
    var locationManager = CLLocationManager()

    @IBOutlet weak var mapview: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpModel()
    }

    func setUpModel() {
        
        trackViewModel = TrackingViewModel()
        
        //1.
        //setup location manager
        locationManager = trackViewModel.setuplocationManager()
        locationManager.delegate = self
        
        //2.
        //Setup mapview
        mapview = trackViewModel.setupMapView()
    }
    
    func drawRoutesandAddAnnotations(annotations: [MKPointAnnotation], polyline: MKPolyline, mapRect: MKMapRect) {
        
        //1.
        //Removing the last annotations
        self.mapview.removeAnnotations(self.mapview.annotations.dropLast())
        
        //2.
        //Removing the overlays
        self.mapview.removeOverlays(self.mapview.overlays)
        
        //3.
        //Add the Annotation to the map view
        self.mapview.addAnnotations(annotations)
        
        //4.
        //Add the polyline to the map view
        self.mapview.addOverlay(polyline, level: MKOverlayLevel.aboveRoads)
        
        //5.
        //Make the annotations to visible in the screen
        self.mapview.setRegion(MKCoordinateRegion(mapRect), animated: true)
    }
}

extension TrackingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //1.
        //Getting the current location
        let location: CLLocation = locations[0] as CLLocation
        
        //2.
        //Passing the location to the view model and it returns the tuple value
        let value = trackViewModel.addLocationandDrawRout(location: location.coordinate)
        
        //3.
        //Get the Annotation, polyline, CoordinateRegion from the value and pass it to the methode update the UI
        drawRoutesandAddAnnotations(annotations: value.annotations, polyline: value.polyline, mapRect: value.mapRect)
    }
}

