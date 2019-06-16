//
//  mapVC.swift
//  On The Map
//
//  Created by Mohammed on 3/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    var studentLocations: [StudentLocation]! {
        return Global.shared.studentLocations
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (studentLocations == nil) {
            reloadStudentLocations(self)
        } else{
            DispatchQueue.main.async {
                self.updateAnnotations()
            }
        }
    }
    
    @IBAction func signout(_ sender: Any) {
        UdacityAPI.delSession{ (error) in
            if let error = error {
                //                self.alert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "studentLocation") != nil {
            let alert = UIAlertController(title: "A posted location needs to be overwritten!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Overwrite", style: .destructive, handler: {(action) in
                self.performSegue(withIdentifier: "mapToNewLocation", sender: self)
            }))
        } else{
            self.performSegue(withIdentifier: "mapToNewLocation", sender: self)
        }
    }
    
    @IBAction func reloadStudentLocations(_ sender: Any) {
        UdacityAPI.Parse.getLocations { (_, error) in
            if let error = error{
                //                self.alert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.updateAnnotations()
            }
        }
    }
    
    func updateAnnotations(){
        var annotations = [MKPointAnnotation]()

        for studentLocation in studentLocations {
            let lat = CLLocationDegrees(studentLocation.latitude ?? 0)
            let long = CLLocationDegrees(studentLocation.longitude ?? 0)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentLocation.firstName ?? ""
            let last = studentLocation.lastName ?? ""
            let mediaURL = studentLocation.mediaURL ?? ""
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            if !mapView.annotations.contains(where: {$0.title == annotation.title}) {
                annotations.append(annotation)
            }
        }
        mapView.addAnnotations(annotations)
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pinId"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.shared
            guard let toOpen = view.annotation?.subtitle!, let url = URL(string: toOpen) else {return}
            app.open(url, options: [:], completionHandler: nil)
        }
    }
}
