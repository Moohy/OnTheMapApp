//
//  UdacityAPI.swift
//  On The Map
//
//  Created by Mohammed on 3/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit
import MapKit

class UdacityAPI {
    static func postSession(with email: String, password: String, completion: @escaping ([String: Any]?, Error?)->()){
        
        // REQUEST and HEADER info
        var req = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // REQUEST BODY
        req.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            if error != nil {
                completion(nil, error)
                return
            }
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range)
            let result = try! JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.allowFragments) as![String:Any]
            completion(result, nil)
        }
        task.resume()
    }
    
    static func delSession(completion: @escaping (Error?) -> ()){
        var req = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        req.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN"{
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            req.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            if error != nil {
                completion(error)
                return
            }
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range)
            completion(nil)
        }
        task.resume()
    }
    
    class Parse{
        static func postLocation(link: String, coordinate: CLLocationCoordinate2D, locationName: String, completion: @escaping (Error?) -> ()){
            var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error…
                    completion(nil)
                    return
                }
                print(String(data: data!, encoding: .utf8)!)
                completion(nil)
            }
            task.resume()
        }
        
        static func getLocations(completion: @escaping ([StudentLocation]?, Error?) -> ()){
            var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100&order=-updatedAt")!)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error...
                    completion(nil, error)
                    return
                }
                
                let dict = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                guard let results = dict["results"] as? [[String:Any]] else {return}
                let resultsData = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
                let studLocations = try! JSONDecoder().decode([StudentLocation].self, from: resultsData)
                Global.shared.studentLocations = studLocations
                completion(studLocations, nil)
//                print(studLocations[0])
            }
            task.resume()
        }
    }
}


