//
//  MVCMapView.swift
//  OnTheMap
//
//  Created by Ransom Barber on 5/27/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? PinData {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }
    
    // just practice for tapping on a control
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let pin = view.annotation as! PinData
        let urlString = pin.urlString
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let webController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        webController.urlRequest = request
        webController.authenticating = false
        
        self.presentViewController(webController, animated: true, completion: nil)
        
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
}
