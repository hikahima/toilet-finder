//
//  ViewController.swift
//  toilet finder
//
//  Created by Yanfei on 2018/1/10.
//  Copyright © 2018年 Yanfei. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController,CLLocationManagerDelegate,UISearchDisplayDelegate{
   
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        viewMarkers()
    //Remove some markers according to user's options.
        for i in 0..<name.count{
         if allMarkers[i] != nil{
            if allMarkers[i].map==mapView{
                if setFemale==true&&female[i]==false{
                    allMarkers[i].map=nil
                }
                if setMale==true&&male[i]==false{
                    allMarkers[i].map=nil
                }
                if setBabychang==true&&babychange[i]==false{
                    allMarkers[i].map=nil
                }
                if setDrinkingwater==true&&drinkingWater[i]==false{
                    allMarkers[i].map=nil
                }
                if setParking==true&&parking[i]==false{
                    allMarkers[i].map=nil
                }
              }
            }
        }
    }
    @IBAction func getCloset(_ sender: Any) {
        var currentPlace:CLLocationCoordinate2D = current.coordinate
        var closetPlace:CLLocationCoordinate2D = current.coordinate
        var minDistance:Double = 100000.0
        var index : Int = -1
        if selectedPlace != nil{
            currentPlace = (selectedPlace?.coordinate)!
        }
    // Find the closet marker based on the geodistance between markers and user's current location.
        for i in 0..<name.count{
            if allMarkers[i] != nil{
            let positions = CLLocationCoordinate2D(latitude:latitude[i], longitude: longitude[i])
            if allMarkers[i].map==mapView && GMSGeometryDistance(positions,currentPlace) < minDistance{
                minDistance = GMSGeometryDistance(positions,currentPlace)
                closetPlace = positions
                index = i
            }
        }
    }
  // Show an alert window when there is no toilet found.
        if index == -1{
            let alert = UIAlertController(title: "Not found" ,message: "There is no toilet within 10km.", preferredStyle: .alert)
            let ok = UIAlertAction(title:"OK",style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
        }else{
    // Draw the path from user's location to the closet toilet, and show the time walking.
            drawRoutes(from: currentPlace,to: closetPlace)
            showCost(from: currentPlace,to: closetPlace)
        }
    }
    
        @IBAction func getDirections(_ sender: Any) {
 // Show an alert window when user forget to choose the destination.
 // Open google.com to get directions.
        if mapView.selectedMarker == nil || mapView.selectedMarker?.title == selectedPlace?.name{
            let alert = UIAlertController(title: "Destination not found" ,message: "Please choose your destination.", preferredStyle: .alert)
            let okAction = UIAlertAction(title:"OK",style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil)
        }else{
            let lat : Double = (mapView.selectedMarker?.position.latitude)!
            let long : Double = (mapView.selectedMarker?.position.longitude)!
            var url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(String(describing: lat)),\(String(describing: long))")
            if selectedPlace != nil{
                let origLat : Double = (selectedPlace?.coordinate.latitude)!
                let origLong : Double = (selectedPlace?.coordinate.longitude)!
                url = URL(string: "https://www.google.com/maps/dir/?api=1&origin=\(String(describing: origLat)),\(String(describing: origLong))&destination=\(String(describing: lat)),\(String(describing: long))")
        }
            let alert = UIAlertController(title: "Get directions",
                                          message: "Do you want to open Google.com?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "OK", style: .default, handler: {
                action in
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
     }
    }
  
    var name = Array<String>()
    var latitude = Array<Double>()
    var longitude = Array<Double>()
    var female = Array<Bool>()
    var male = Array<Bool>()
    var openingHours = Array<String>()
    var parking = Array<Bool>()
    var drinkingWater = Array<Bool>()
    var babychange = Array<Bool>()
    var allMarkers=Array<GMSMarker!>()
    var setMale:Bool = false
    var setFemale:Bool = false
    var setParking:Bool = false
    var setDrinkingwater:Bool = false
    var setBabychang:Bool = false
    var polyline = GMSPolyline()
    var label = UILabel()
    
    var locationManager = CLLocationManager()
    var current = CLLocation()
    var didFindMyLocation = false
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var selectedPlace: GMSPlace?
    var myLocationMarker: GMSMarker!

    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        locationManager.startUpdatingLocation()
        
   // Add the default map.
        let camera = GMSCameraPosition.camera(withLatitude: -37.5, longitude:144.8, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        self.view = mapView
        
    // Add a search bar to the navigation bar.
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.placeholder = "Find your location"
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
        
   // Add a directions button.
        let directionsButton = UIButton(type: UIButtonType.system)
        directionsButton.frame = CGRect(x: 348, y: 610, width: 50, height: 50)
        directionsButton.setImage(UIImage(named:"directions"), for: .normal)
        directionsButton.addTarget(self, action: #selector(ViewController.getDirections(_:)), for: .touchDown)
        self.view.addSubview(directionsButton)
        
   // Add a lebel to show the time walking to the closet toilet.
        label.frame = CGRect(x: 0, y: 64, width: 414, height: 52)
        label.textAlignment = .center
        label.textColor = UIColor.blue
        label.font=UIFont.init(name:"Arial", size:30)
        self.view.addSubview(label)
        
         readjson()
         createAllMarkers()
    }
    
    // When user select the place through search bar, move the camera and create a marker.
    func selectPlace(){
        let camera = GMSCameraPosition.camera(withTarget: (self.selectedPlace?.coordinate)!, zoom:15.0)
        mapView.animate(to: camera)
        
        myLocationMarker = GMSMarker.init()
        myLocationMarker.position = (self.selectedPlace?.coordinate)!
        myLocationMarker.title = selectedPlace?.name
        myLocationMarker.appearAnimation = GMSMarkerAnimation.pop
        myLocationMarker.map = mapView
    }
    
    // Load the local JSON file and store the required date in arrays.
    func readjson(){
        let path = Bundle.main.path(forResource: "toilet", ofType: "json")
        let jsonData=NSData(contentsOfFile: path!)
        do {
            let parsedData = try JSONSerialization.jsonObject(with: jsonData! as Data, options:[]) as! [String:Any]
            let features = parsedData["features"] as! NSArray
            for item in features {
                let obj = item as! NSDictionary
                let properties:NSDictionary! = obj.value(forKey: "properties") as? NSDictionary
                name.append((properties.value(forKey: "name") as?String)!)
                latitude.append((properties.value(forKey: "latitude") as?Double)!)
                longitude.append((properties.value(forKey: "longitude") as?Double)!)
                male.append((properties.value(forKey: "male") as?Bool)!)
                female.append((properties.value(forKey: "female") as?Bool)!)
                parking.append((properties.value(forKey: "parking") as?Bool)!)
                drinkingWater.append((properties.value(forKey: "drinking_water") as?Bool)!)
                babychange.append((properties.value(forKey: "baby_change") as?Bool)!)
                if (properties["opening_hours"] as? String) != nil {
                     openingHours.append((properties.value(forKey: "opening_hours") as?String?)!!)
                }
                else {
                     openingHours.append("All hours")
                }
            }
        }catch{print("invaild json")}
    }
    
    // Create all the markers of the toilets in Melbourne, and store them in an array.
    func createAllMarkers(){
        let femaleImage = UIImage(named:"female")!.withRenderingMode(.alwaysOriginal)
        let femaleView = UIImageView(image: femaleImage)
        let maleImage = UIImage(named:"male")!.withRenderingMode(.alwaysOriginal)
        let maleView = UIImageView(image: maleImage)
        let unisexImage = UIImage(named:"unisex")!.withRenderingMode(.alwaysOriginal)
        let unisexView = UIImageView(image: unisexImage)
        for i in 0..<name.count{
                let markers = GMSMarker(position:CLLocationCoordinate2D(latitude:latitude[i], longitude: longitude[i]))
                markers.title = name[i]
                allMarkers.append(markers)
            if female[i] == true  && male [i] == false{
                 allMarkers[i].iconView = femaleView
            }else if female[i] == false && male[i] == true{
                 allMarkers[i].iconView = maleView
            }else if female[i] == true && male[i] == true{
                allMarkers[i].iconView = unisexView
            }else{
                allMarkers[i] = nil
            }
        }
    }
    
// Add the markers of toilets on the map within 10km based on the user's location.
    func viewMarkers(){
        var currentPlace:CLLocationCoordinate2D = current.coordinate
        if selectedPlace != nil{
            currentPlace = (selectedPlace?.coordinate)!
        }
        for i in 0..<name.count{
            if allMarkers[i] != nil{
            let positions = CLLocationCoordinate2D(latitude:latitude[i], longitude: longitude[i])
            if GMSGeometryDistance(positions,currentPlace)<=10000{
                allMarkers[i].map=mapView
            }
          }
        }
    }
    
// Draw the shortest path between 2 places through Google Directions API.
    func drawRoutes(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=walking&key=AIzaSyAAkQbaZjhJkVgSCypYeACDQEDp3I_2c3M")!
      
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        let Routes = json["routes"] as! NSArray
                        let route = Routes[0] as! NSDictionary
                        let overviewPolyline:NSDictionary = route.value(forKey: "overview_polyline") as! NSDictionary
                        let polyline = overviewPolyline.object(forKey: "points") as! String
                        
                        DispatchQueue.main.async(execute: {
                            self.polyline.map = nil
                            let path = GMSPath(fromEncodedPath: polyline)
                            self.polyline = GMSPolyline(path: path)
                            self.polyline.strokeWidth = 3.0
                            self.polyline.map = self.mapView
                        })
                    }
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
//Show the time walking from origin to destination through Google Distance Matrix API.
    func showCost(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(origin.latitude),\(origin.longitude)&destinations=\(destination.latitude),\(destination.longitude)&mode=walking&key=AIzaSyAXaFFvVW4pMNNYAlFoc7PYh-WbF0agqCA")!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        let Rows = json["rows"] as! NSArray
                        let row = Rows[0] as! NSDictionary
                        let Elements = row ["elements"] as! NSArray
                        let element = Elements[0] as!NSDictionary
                        let duration = element ["duration"] as! NSDictionary
                        let durationText = duration.value(forKey: "text") as! String
                        DispatchQueue.main.async {
                            self.label.text = " \( durationText) for walking"
                        }
                    }
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ViewController:GMSMapViewDelegate {
    
    // Move the camera to user's current location, and show the markers of the toilets within 10 km.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        current = locations.last!
        let camera = GMSCameraPosition.camera(withLatitude: current.coordinate.latitude,
                                              longitude: current.coordinate.longitude,
                                              zoom: 15.0)
            mapView.animate(to: camera)
            viewMarkers()
       
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
  // When user tap on mylocation button, move the camera and clear the previous results of closet button and user's selected location.
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        selectedPlace=nil
        DispatchQueue.main.async {
            self.label.text = nil
        }
        let camera = GMSCameraPosition.camera(withLatitude: current.coordinate.latitude,
                                              longitude: current.coordinate.longitude,
                                              zoom: 15.0)
        mapView.animate(to: camera)
        return true
    }

// Display a custom infowindow when user click a marker.
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = Bundle.main.loadNibNamed("infoWindow", owner: self, options: nil)?.first! as! infoWindow
        infoWindow.name.text = marker.title
        for i in 0..<name.count{
            if marker.title == name[i]{
                infoWindow.open.text = openingHours[i]
                if babychange[i] == true{infoWindow.babychange.text = "Baby Change : Yes"
                }else{infoWindow.babychange.text = "Baby change : No" }
                if parking[i] == true{infoWindow.parking.text = "Parking : Yes"
                }else{infoWindow.parking.text = "Parking : No" }
                if drinkingWater[i] == true{infoWindow.water.text = "Drinking Water : Yes"
                }else{infoWindow.water.text = "Drinking Water : No" }
            }
          }
        return infoWindow
    }
    
}

extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    // Handle the selection of the search tabel.
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Remove the previous marker of user's location.
        if selectedPlace != nil{
            myLocationMarker.map=nil
            selectedPlace=place
            selectPlace()
        }else{
        selectedPlace=place
        selectPlace()
        }
    //Clear the previous results of closet button.
        DispatchQueue.main.async {
            self.label.text = nil
        }
         viewMarkers()
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

