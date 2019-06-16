//
//  shareVC.swift
//  On The Map
//
//  Created by Mohammed on 3/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ShareVC: UIViewController {
    
    var locationCoordinate: CLLocationCoordinate2D!
    var locationName: String!

    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(locationCoordinate, locationName)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
        
        let viewRegion = MKCoordinateRegion(center: locationCoordinate!, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    @IBAction func submit(_ sender: Any) {
        UdacityAPI.Parse.postLocation(link: linkTextField.text ?? "", coordinate: locationCoordinate, locationName: locationName) { (error) in
            if let error = error {
//                self.alert(title: "Error", message: error.localizedDescription)
                return
            }
            UserDefaults.standard.set(self.locationName, forKey: "studentLocation")
            DispatchQueue.main.async {
                self.parent!.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension ShareVC: MKMapViewDelegate {
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
