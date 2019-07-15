//
//  ViewController.swift
//  SunriseSunset
//
//  Created by Horbach on 20.03.19.
//  Copyright © 2019 Horbach. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var placesClient: GMSPlacesClient!
    
    
    @IBOutlet weak var SunriseLabel: UILabel!
    
    @IBOutlet weak var SunsetLabel: UILabel!
    
    @IBOutlet weak var adressLabel: UILabel!
    
    @IBAction func getCurrentPlace(_ sender: Any) {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            
            self.adressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.adressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        })
    }
    
    
    struct Result : Codable {
        let results : Sun
    }
    
    struct Sun: Codable {
        let sunrise: String
        let sunset: String
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         placesClient = GMSPlacesClient.shared()
   
        let locationManager = CLLocationManager()
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
            }
        }
        
        // 1
        let urlString = "https://api.sunrise-sunset.org/json?lat=49.841952&lng=24.0315921&date=today"
        guard let url = URL(string: urlString) else { return }
        
        // 2
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                // 3
                //Decode data
                let JSONData = try JSONDecoder().decode(Result.self, from: data)
                
                // 4
                //Get back to the main queue
                DispatchQueue.main.async {
                  self.SunriseLabel.text = JSONData.results.sunrise
                  self.SunsetLabel.text = JSONData.results.sunset
                    
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            // 5
            }.resume()
        
    }


}

