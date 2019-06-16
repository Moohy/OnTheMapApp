//
//  NewPinVC.swift
//  On The Map
//
//  Created by Mohammed on 3/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit
import CoreLocation

class NewPinVC: UIViewController {
    
    var locationCoordinate: CLLocationCoordinate2D!
    var locationName: String!

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!

    @IBAction func find(_ sender: UIButton) {
        updateUI(processing: true)
        guard let locationName = locationTextField.text?.trimmingCharacters(in: .whitespaces), !locationName.isEmpty else{
//            alert(title: "Warning", message: "Please type a location!")
            updateUI(processing: false)
            return
        }
        print(locationName)
        getCoordinateFrom(locationName) { (coordinate) in
            self.locationCoordinate = coordinate
            self.locationName = locationName
            print(locationName, coordinate)
            self.updateUI(processing: false)
            self.performSegue(withIdentifier: "fromNewPinVCToShareVC", sender: self)
        }
    }
    
    func getCoordinateFrom(_ location: String, completion: @escaping (_ coordinate: CLLocationCoordinate2D) -> () ) {
        CLGeocoder().geocodeAddressString(location) { marks, error in
            guard error==nil else{
                print("somthing is wrong here!!")
                return
            }
            completion(marks!.first!.location!.coordinate)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromNewPinVCToShareVC"{
            let vc = segue.destination as! ShareVC
            vc.locationCoordinate = self.locationCoordinate
            vc.locationName = self.locationName
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    func updateUI(processing: Bool) {
        DispatchQueue.main.async{
            self.findButton.isEnabled = !processing
        }
    }


}
