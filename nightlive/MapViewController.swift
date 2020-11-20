//
//  MapViewController.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 19.04.17.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: ViewController, IndicatorInfoProvider, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myPositionButton: UIButton!
    
    var isRetrievingItems = false
    var filterSet = false
    var todaysWeekDay = getTodaysWeekday()
    
    var filteredAnnotations = [LocationAnnotation]()
    
    var currentUserLocationLatLng = (Double(),Double())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapViewController viewDidLoad executed")
        // Do any additional setup after loading the view.
        
        instance_mapVC = self
        
        //UserLocation in Model
        setupLocationManager()
        
        mapView.mapType = MKMapType.standard
        mapView.delegate = self
        
        let location = CLLocationCoordinate2D(latitude: 48.366512, longitude: 10.894446)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        //Check if clubs are already loaded, if not show activity Indicator
        if clubAnnotations.isEmpty && barAnnotations.isEmpty {
            activityIndicator.startAnimating()
            isRetrievingItems = true
            setMapEnableModeTo(enable: false)
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: false)
        }
        else {
            //check Filter
            if global_mapsFilterSet {
                filterBy(name: global_mapsFilteredLocation, type: "noFilter", open: "noFilter", happyHour: "noFilter", radius: 0)
            }
            else {
                displayAnnotations()
            }
            
            
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Map")
        instance_landingPageVC?.adjustViewToTabBarSelection(newController: self)
        
        if isAppAuthorizedToUseLocation() {
            startUpdatingLocation()
            mapView.showsUserLocation = true
            myPositionButton.isHidden = false
        }
        else {
            myPositionButton.isHidden = true
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isAppAuthorizedToUseLocation() {
            endUpdatingLocation()
            mapView.showsUserLocation = false
        }
    }
    
    //MARK: - Logic
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Map")
    }
    
    //MARK: - User Interaction
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let locationAnnotation = view.annotation as! LocationAnnotation
        let placeName = locationAnnotation.title
        let placeSubtitle = locationAnnotation.subtitle
        let location = locationAnnotation.location
        
        if location is Club {
            global_filteredClub = location.nightlive_display_name
            global_clubsFilterSet = true
            instance_clubsVC?.filterBy(name: location.nightlive_display_name, open: "noFilter", happyHour: "noFilter")
            instance_pagerVC?.moveToViewController(at: 2)
        }
        else if location is Bar {
            let ac = UIAlertController(title: placeName, message: placeSubtitle, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    @IBAction func myPositionButtonPressed(_ sender: UIButton) {
        centerMapOnUserLocation()
    }
    
    //MARK: - Filter
    func removeAllFilters() {
        filterSet = false
        instance_landingPageVC?.setFilterButtonStateTo(filterSet: false)
        displayAnnotations()
    }
    
                                //clubs,bars,all         today,now,noFilter
    func filterBy(name: String, type: String, open: String, happyHour: String, radius: Double) {
        
        let allAnnotations = clubAnnotations + barAnnotations
        filteredAnnotations.removeAll()
        var newAnnotations = [LocationAnnotation]()
        newAnnotations.removeAll()
        
        var filterGroup = 0
        while true {
            
            //NAME
            if name != "noFilter" {
                var hasMatch = false
                for annotation in allAnnotations {
                    let location = annotation.location
                    if location.nightlive_display_name == name {
                        hasMatch = true
                        filteredAnnotations.append(annotation)
                        break
                    }
                }
                if hasMatch {
                    //this is to stop the while loop
                    break
                }
            }
            
            //TYPE
            if filterGroup == 0 {
                if type == "clubs" {
                    filteredAnnotations = clubAnnotations
                }
                else if type == "bars" {
                    filteredAnnotations = barAnnotations
                }
                else {
                    filteredAnnotations = allAnnotations
                }
                //go to next Filtergroup
                newAnnotations.removeAll()
                filterGroup += 1
                continue
            }
         
            //OPEN
            if filterGroup == 1 {
                for annotation in filteredAnnotations {
                    let location = annotation.location
                    if open == "today" {
                        if isLocationOpen(location: location, isNow: false) {
                            newAnnotations.append(annotation)
                        }
                        else if isLocationOpen(location: location, isNow: true) {
                            newAnnotations.append(annotation)
                        }
                    }
                    else if open == "now" {
                        if isLocationOpen(location: location, isNow: true) {
                            newAnnotations.append(annotation)
                        }
                    }
                    else {
                        newAnnotations.append(annotation) 
                    }
                    
                    
                }
                //go to next Filtergroup
                filteredAnnotations = newAnnotations
                newAnnotations.removeAll()
                filterGroup += 1
                continue
            }
            
            //HAPPYHOUR
            if filterGroup == 2 {
                for annotation in filteredAnnotations {
                    let location = annotation.location
                    if happyHour == "today" {
                        if isLocationInHappyHour(location: location, isNow: false) {
                            newAnnotations.append(annotation)
                        }
                        else if isLocationInHappyHour(location: location, isNow: true) {
                            newAnnotations.append(annotation)
                        }
                    }
                    else if happyHour == "now" {
                        if isLocationInHappyHour(location: location, isNow: true) {
                            newAnnotations.append(annotation)
                        }
                    }
                    else {
                        newAnnotations.append(annotation)
                    }
                    
                    
                }
                //go to next Filtergroup
                filteredAnnotations = newAnnotations
                newAnnotations.removeAll()
                filterGroup += 1
                continue
            }
            
            //RADIUS
            if filterGroup == 3 {
                for annotation in filteredAnnotations {
                    let location = annotation.location
                    if radius > 0 {
                        if isLocationWithinRadius(location: location, radius: radius) {
                            newAnnotations.append(annotation)
                        }
                    }
                    else {
                        //no Filter
                        newAnnotations.append(annotation)
                    }
                    
                    
                }
                //finished
                filteredAnnotations = newAnnotations
                break
            }
            
        }
        
        if name == "noFilter" && type == "noFilter" && open == "noFilter" && happyHour == "noFilter" && radius <= 0 {
            filterSet = false
            instance_landingPageVC?.setFilterButtonStateTo(filterSet: filterSet)
        }
        else {
            filterSet = true
            instance_landingPageVC?.setFilterButtonStateTo(filterSet: filterSet)
        }
        displayAnnotations()
        
    }
    
    //MARK: - UI
    func displayAnnotations() {
        DispatchQueue.main.async { [unowned self] in
            if self.filterSet {
                self.mapView.removeAnnotations(barAnnotations)
                self.mapView.removeAnnotations(clubAnnotations)
                self.mapView.addAnnotations(self.filteredAnnotations)
            }
            else {
                self.mapView.addAnnotations(barAnnotations)
                self.mapView.addAnnotations(clubAnnotations)
                instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: true)
            }
            self.setMapEnableModeTo(enable: true)
            self.isRetrievingItems = false
        }
        mapView.reloadInputViews()
    }
    
    
    func setMapEnableModeTo(enable: Bool) {
        mapView.isUserInteractionEnabled = enable
        if enable {
            mapView.alpha = 1
            activityIndicator.stopAnimating()
        }
        else {
            mapView.alpha = 0.5
            activityIndicator.startAnimating()
        }
        
    }
    
    //MARK: - User Location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let lat = userLocation.location?.coordinate.latitude {
            if let lng = userLocation.location?.coordinate.longitude {
                currentUserLocationLatLng.0 = lat
                currentUserLocationLatLng.1 = lng
            }
            else {
                currentUserLocationLatLng.0 = 0.0 //something went wrong
                currentUserLocationLatLng.1 = 0.0
            }
        }
        else {
            currentUserLocationLatLng.0 = 0.0 //something went wrong
            currentUserLocationLatLng.1 = 0.0
        }
    }
    
    func centerMapOnUserLocation() {
        let userLocation = mapView.userLocation
        
        if let lat = userLocation.location?.coordinate.latitude {
            if let lng = userLocation.location?.coordinate.longitude {
                currentUserLocationLatLng.0 = lat
                currentUserLocationLatLng.1 = lng
                
                let lat = currentUserLocationLatLng.0
                let lng = currentUserLocationLatLng.1
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.mapView.setRegion(region, animated: true)
                mapView.reloadInputViews()
            }
            else {
                currentUserLocationLatLng.0 = 0.0 //something went wrong
                currentUserLocationLatLng.1 = 0.0
            }
        }
        else {
            currentUserLocationLatLng.0 = 0.0 //something went wrong
            currentUserLocationLatLng.1 = 0.0
        }
        
    }
    
    func isLocationWithinRadius(location: Location, radius: Double) -> Bool {
        
        //user
        let userLat = currentUserLocationLatLng.0
        let userLng = currentUserLocationLatLng.1
        let userLocation = CLLocation(latitude: userLat, longitude: userLng)
        
        //location of club/bar
        //usually every annotation that is on map has lat and lng, so no check required... but safety...
        if let locationLat = location.google_location_lat {
            if let locationLng = location.google_location_lng {
                let locationLocation = CLLocation(latitude: locationLat, longitude: locationLng)
                let distance = userLocation.distance(from: locationLocation) //Double in Meters
                if distance <= radius {
                    return true
                }
            }
        }
        
        return false
    }
    
    //MARK: - MapView Data Source
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? LocationAnnotation {
            let identifier = "Location"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.isEnabled = true
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
                
                
                
                
            }
            
            //Nachdenken ob man die anderen Sachen auch runterzieht???
            let location = annotation.location
            switch location {
            case is Club:
                view.pinTintColor = UIColor.wgwLowAlphaDarkBlue()
            case is Bar:
                view.pinTintColor = UIColor.darkRedLowAlpha()
            default:
                view.pinTintColor = UIColor.cyan
            }
            
            var specialColorSet = false
            
            if isLocationCurrentlyInHappyHour(location: location).0 {
                if location is Club {
                    view.pinTintColor = UIColor.wgwOrange()
                    specialColorSet = true
                }
                else {
                    view.pinTintColor = UIColor.wgwOrange()
                    specialColorSet = true
                }
            }
            
            if !specialColorSet {
                if location.google_openingHours_provided {
                    if location.google_open_now != nil {
                        if location.google_open_now! {
                            if location is Club {
                                view.pinTintColor = UIColor.wgwDarkBlue()
                                specialColorSet = true
                            }
                            else {
                                view.pinTintColor = UIColor.darkRed()
                                specialColorSet = true
                            }
                        }
                    }
                    else {
                        let oh = location.getHappyHourForWeekday(weekday: todaysWeekDay)
                        if oh != "Geschlossen" {
                            if location is Club {
                                view.pinTintColor = UIColor.wgwDarkBlue()
                                specialColorSet = true
                            }
                            else {
                                view.pinTintColor = UIColor.darkRed()
                                specialColorSet = true
                            }
                        }
                    }
                }
            }
            
            
            
            
            return view
        }
        return nil
    }
    
    
    //ANIMATION FOR ANNOTATION DROP
    //
    //
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        var i = -1;
        for view in views {
            i += 1;
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint  =  MKMapPointForCoordinate(view.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue;
            }
            
            let endFrame:CGRect = view.frame;
            
            // Move annotation out of view
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - self.view.frame.size.height, width: view.frame.size.width, height: view.frame.size.height)
            
            // Animate drop
            let delay = 0.03 * Double(i)
            UIView.animate(withDuration: 0.5, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations:{() in
                view.frame = endFrame
                // Animate squash
            }, completion:{(Bool) in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations:{() in
                    view.transform = CGAffineTransform(scaleX: 1.0, y: 0.6)
                    
                }, completion: {(Bool) in
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations:{() in
                        view.transform = CGAffineTransform.identity
                    }, completion: nil)
                })
                
            })
        }
    }
    
    
    
}


