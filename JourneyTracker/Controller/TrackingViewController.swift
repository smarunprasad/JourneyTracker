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

class TrackingViewController: UIViewController {
    
    private var trackViewModel: TrackingViewModel!
    var trackingModel: TrackingModel!
    var isUserIntracked: Bool!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tractingSwitch: UISwitch! {
        didSet {
            self.tractingSwitch.isOn = KeychainManager.getIsTrackingStatusFromWapper()
        }
    }
    @IBOutlet weak var trackMeLabel: UILabel! {
        didSet {
            self.trackMeLabel.roundCorner(radius: 5)
        }
    }
    
    @IBOutlet weak var recenterButton: UIButton! {
        didSet {
            self.recenterButton.roundCorner(radius: self.recenterButton.frame.width/2)
            self.recenterButton.isHidden = true
        }
    }
    
    //MARK:- View init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        setupModel()
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
        
        //2.
        //init the viewmodel
        self.trackViewModel = TrackingViewModel()
    }
    
    func setupModel() {
        
        self.view.showLoadingIndicator()
        
        //Check the trackingModel variable and change the UI based on screen
        //To change the mapview with journey data or current data
        if self.trackingModel == nil {
            
//            KeychainManager.removeWapperForKey(key: Constants.KeyChain.isTracking)
//            KeychainManager.removeWapperForKey(key: Constants.KeyChain.journey)
            //1.
            //Init
            self.trackViewModel.isForTracking = true
            self.trackViewModel.isTracking = KeychainManager.getIsTrackingStatusFromWapper()
            self.trackViewModel.isSourceLocationCalled = false
            self.trackViewModel.pointAnnotation = [MKPointAnnotation]()
            self.trackViewModel.polyline = MKPolyline()
            self.trackViewModel.trackingModel = nil
            self.trackViewModel.sourceLocation =  self.trackViewModel.locationManager.location ?? CLLocation()
            self.trackingModel = nil
            self.isUserIntracked = false
            
            if let userLocation = self.trackViewModel.locationManager.location {
                self.trackViewModel.sourceLocation = userLocation
            }
            
            if KeychainManager.getIsTrackingStatusFromWapper() == true {
                
                //2.
                //Creating the variable
                var allJourney: [TrackingModel] =  [TrackingModel]()
                
                //3.
                //Get all values from the keychain
                allJourney = KeychainManager.getALLDataFromWapper()
                
                //4.
                //checking the array contains the value
                //Getting the last object to update the the journey id in keychain
                if allJourney.isEmpty == false, let journey = allJourney.last {
                    
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
            
            self.trackViewModel.sourceLocation = CLLocation.getLocationFrom(lat: self.trackingModel.sourceLat, long: self.trackingModel.sourceLong)
            
            //1.
            //Hide the switch & lable
            self.trackMeLabel.isHidden = true
            self.tractingSwitch.isHidden = true
            self.trackViewModel.isForTracking = false
            
            //2.
            //Passing the value to view model to update the map
            self.trackViewModel.setupJouneyPoints(trackingModel: self.trackingModel)
        }
    }
    func setupLocationManagerandZoomLevel() {
        
        self.recenterButton.isHidden = false
        self.trackViewModel.isSourceLocationCalled = false
        self.trackViewModel.locationManager.delegate = self
        self.trackViewModel.locationManager.startUpdatingLocation()
        //2.
        //Zoom to user location
        if let userLocation = self.trackViewModel.locationManager.location {
            
            self.trackViewModel.sourceLocation = userLocation
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(viewRegion, animated: false)
        }
    }
    
    func setupMapforNotTrackingState() {
        
        self.recenterButton.isHidden = true

        //1.
        //Removing all annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        //2.
        //Removing all overlays
        self.mapView.removeOverlays(self.mapView.overlays)
        
        //3.
        //Zoom to user location
        if let userLocation = self.trackViewModel.locationManager.location {
            
            self.trackViewModel.sourceLocation = userLocation
            let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(viewRegion, animated: true)
        }
        
        //4.
        self.trackViewModel.locationManager.stopUpdatingLocation()
        
        self.view.hideLoadingIndicator()
        
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
        
        //show alert
        trackViewModel.alertBlock = { message in
            
            self.showOkButtonAlert(message: message)
        }
    }
    
    
    //MARK:- Action methods
    @IBAction func trackMeValueChanged(_ sender: Bool) {
        
        trackViewModel.switchValueChanged(state: tractingSwitch.isOn)
    }
    
    @IBAction func recenterButtonTapped(_ sender: Any) {
        
        isUserIntracked = true
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
    }
    //MARK:- Helper
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
            self.trackViewModel.isSourceLocationCalled = false
            self.trackViewModel.pointAnnotation = [MKPointAnnotation]()
            self.trackViewModel.polyline = MKPolyline()
            self.trackViewModel.trackingModel = nil
            self.trackViewModel.sourceLocation =  self.trackViewModel.locationManager.location ?? CLLocation()
            self.trackingModel = nil
            self.isUserIntracked = false
        }
    }
    
    func drawRoutesandAddAnnotations(pointAnnotation: [MKPointAnnotation]?, polyline: MKPolyline) {
        
        if self.mapView.annotations.isEmpty == false {
            //1.
            //Removing the annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        //3.
        //Add the polyline to the map view if it present
        self.mapView.addOverlay((polyline), level: MKOverlayLevel.aboveRoads)
        
        
        //2.
        //Add the placemark to the map view if it present
        if let pointAnnotation = pointAnnotation {
            
            self.mapView.addAnnotations(pointAnnotation)
        }
        
        if self.isUserIntracked == false {
            //4.
            //Make the annotations to visible in the screen if it present
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
        isUserIntracked = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.view.hideLoadingIndicator()
        }
    }
    
    func showOkButtonAlert(message: String) {
        
        self.showAlert(title:Constants.AppName.appName, message: message, OkButtonBlock: {
            
        })
    }
}

extension TrackingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if isUserIntracked == false {
            isUserIntracked = true
        }
    }
}

