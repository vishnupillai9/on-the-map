//
//  MapViewController.swift
//  On The Map
//
//  Created by Vishnu on 23/03/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        getData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Set the navigation bar title
        self.parentViewController!.navigationItem.title = "On The Map"
        
        // Create and set left bar button item
        self.parentViewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTouch")
        
        // Create and set right bar button item
        self.parentViewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshData")
    }
    
    // MARK: - Map View Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        // Adding detail button
        let button = UIButton(type: UIButtonType.DetailDisclosure)
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            // When user taps on detail button, open URL in Safari
            UIApplication.sharedApplication().openURL(NSURL(string: view.annotation!.subtitle!!)!)
        }
    }
    
    // MARK: - Helpers
    
    /// Presents information posting view when pin button is touched
    func pinButtonTouch() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    /// Gets student locations
    func getData() {
        ParseClient.sharedInstance().getStudentLocations { (success, studentData, errorString) -> Void in
            if success {
                self.appDelegate.students = studentData!
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    for student in self.appDelegate.students {
                        //Add pin to the map for every student
                        let location = CLLocationCoordinate2DMake(student.latitude!, student.longitude!)
                        let pin = MKPointAnnotation()
                        pin.coordinate = location
                        if let firstName = student.firstName {
                            if let lastName = student.lastName {
                                pin.title = firstName + " " + lastName
                            } else {
                                pin.title = firstName
                            }
                        }
                        pin.subtitle = student.mediaURL!
                        self.mapView.addAnnotation(pin)
                    }
                }
            } else {
                // Alert view to inform the user getting student locations failed
                let alert = UIAlertController(title: "Failed to get student locations", message: "Fetching student locations from server failed", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    /// Remove all pins from map before refreshing data
    func refreshData() {
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)
        getData()
    }
    
}
