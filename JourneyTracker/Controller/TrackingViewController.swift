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
    var trackingModel: TrackingModel!
    fileprivate var locationManager = CLLocationManager()
    fileprivate var sourceLocation = CLLocation()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tractingSwitch: UISwitch! {
        didSet {
            self.tractingSwitch.isOn = KeychainManager.getIsTrackingStatusFromWapper()
        }
    }
    @IBOutlet weak var trackMeLabel: UILabel!

    //MARK:- View init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        bindValues()
    }
    
    func initialSetup() {
        
        //1.
        //Setup mapview
        self.mapView.showsUserLocation = true
        self.mapView.isZoomEnabled = true
        self.mapView.showsCompass = true
        self.mapView.layoutMargins = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20)
        self.mapView.delegate = self
     
        self.trackViewModel = TrackingViewModel()
        
        //2.
        // locationManager setup
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 2
        self.locationManager.delegate = self
        
        //To change the mapview with journey data or current data
        if self.trackingModel == nil {
            
//                        KeychainManager.removeWapperForKey(key: Constants.KeyChain.isTracking)
//                        KeychainManager.removeWapperForKey(key: Constants.KeyChain.journey)
            
            self.trackViewModel.isForTracking = true
            self.trackViewModel.isTracking = KeychainManager.getIsTrackingStatusFromWapper()

            //FIXME: Testing
            self.sourceLocation = CLLocation.init(latitude: 51.5079, longitude: 0.1378)

            if KeychainManager.getIsTrackingStatusFromWapper() == true {
                
                //1.
                //Creating the variable
                var allJourney: [TrackingModel] =  [TrackingModel]()
                
                //2.
                //Get all values from the keychain
                allJourney = KeychainManager.getALLDataFromWapper()
                
                //checking the array contains the value
                //Getting the last object to update the the journey id in keychain
                if allJourney.isEmpty == false, let journey = allJourney.last {
                    
                    //4.
                    //Passing the current location to the view model
                    self.trackViewModel.sourceLocation = self.sourceLocation

                    //5.
                    //Passing the value to view model to update the map
                    self.trackViewModel.setupJouneyPoints(trackingModel: journey)
                }
                //6.
                //Then draw the route between the last point and the current location
                setupLocationManagerandZoomLevel()
            }
            else {
                //Setup the mapview to zoom to current location & disable the location update
                self.setupMapforNotTrackingState()
            }
        }
        else {
            
            //FIXME: Testing
             self.sourceLocation = CLLocation.getLocationFrom(lat: self.trackingModel.sourceLat, long: self.trackingModel.sourceLong)

            //1.
            //Passing the start location to the view model
            self.trackViewModel.sourceLocation = self.sourceLocation

            //2.
            //Hide the switch & lable
            self.trackMeLabel.isHidden = true
            self.tractingSwitch.isHidden = true
            self.trackViewModel.isForTracking = false
            
            //3.
            //Passing the value to view model to update the map
            self.trackViewModel.setupJouneyPoints(trackingModel: self.trackingModel)
        }
    }
    
    func setupLocationManagerandZoomLevel() {

        locationManager.startUpdatingLocation()
        //2.
        //Zoom to user location
        if let userLocation = locationManager.location {
            
          //  self.sourceLocation = userLocation
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(viewRegion, animated: false)
        }
        
        //4.
        //Passing the current location to the view model
        self.trackViewModel.sourceLocation = self.sourceLocation        
    }
    
    func setupMapforNotTrackingState() {
    
        //1.
        //Removing all annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        //2.
        //Removing all overlays
        self.mapView.removeOverlays(self.mapView.overlays)
        
        //3.
        //Zoom to user location
        if let userLocation = self.locationManager.location {
            
            //  self.sourceLocation = userLocation
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(viewRegion, animated: true)
        }
        
            //4.
            self.locationManager.stopUpdatingLocation()
    }
    
    func bindValues() {
        
        //location update handler
        trackViewModel.reloadDataBlock = {
            
            if let polyline = self.trackViewModel.polyline {
                //1.
                //Passing the values to update the map with places and route
                self.drawRoutesandAddAnnotations(pointAnnotation: self.trackViewModel.pointAnnotation, polyline: polyline)
            }
        }
        
        //Switch status handler
        trackViewModel.switchStatChanged = { isEnable in
            
           self.changeMapViewData(isEnable: isEnable)
        }
    }
    
    func changeMapViewData(isEnable: Bool) {
        
        DispatchQueue.main.async {
           
            if isEnable == true {
                
                //2.
                //Setup the mapview to zoom to current location & disable the location update
                self.setupLocationManagerandZoomLevel()
            }
            else {
                
                //Initiate the location manager and update the mapView based on the location changes
                self.setupMapforNotTrackingState()
            }
            
            //reinit
            self.trackViewModel.isTracking = isEnable
            self.trackViewModel.pointAnnotation = [MKPointAnnotation]()
            self.trackViewModel.polyline = MKPolyline()
            self.trackViewModel.trackingModel = nil
            self.trackViewModel.sourceLocation = self.sourceLocation
            self.trackingModel = nil
        }
    }
    
    //MARK:- Action methods
    @IBAction func trackMeValueChanged(_ sender: Bool) {
        
        trackViewModel.switchValueChanged(state: tractingSwitch.isOn)
    }
    
    //MARK:- Helper
    func drawRoutesandAddAnnotations(pointAnnotation: [MKPointAnnotation]?, polyline: MKPolyline) {
        
        if self.mapView.annotations.isEmpty == false {
            //1.
            //Removing the last annotations
            self.mapView.removeAnnotations(self.mapView.annotations.dropLast())
        }
        
        //3.
        //Add the polyline to the map view if it present
        self.mapView.addOverlay((polyline), level: MKOverlayLevel.aboveRoads)
        
        
        //2.
        //Add the placemark to the map view if it present
        if let pointAnnotation = pointAnnotation {

            self.mapView.addAnnotations(pointAnnotation)
        }
        
        //4.
        //Make the annotations to visible in the screen if it present
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
}

extension TrackingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locationManager.stopUpdatingLocation()

        //1.
        //Getting the current location
        let location: CLLocation = locations[0] as CLLocation
        
        //2.
        //Passing the location to the view model to setup the annotations & polyline
        self.trackViewModel.setupMapViewWithLocation(location: location)
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

