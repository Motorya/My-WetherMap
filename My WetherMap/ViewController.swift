//
//  ViewController.swift
//  My WetherMap
//
//  Created by Марк Моторя on 16.12.16.
//  Copyright © 2016 Motorya Mark. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, OpenWeatherMapDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var speedWindLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var time1Text: String!
    var time2Text: String!
    var time3Text: String!
    var time4Text: String!
    
    var icon1: UIImage!
    var icon2: UIImage!
    var icon3: UIImage!
    var icon4: UIImage!
    
    var temp1Text: String!
    var temp2Text: String!
    var temp3Text: String!
    var temp4Text: String!

    
    @IBAction func cityTapedButton(_ sender: UIBarButtonItem) {
        displayCity()
    }
    
    var locationManager: CLLocationManager = CLLocationManager()
    var openWeather = MMOpenWeatherMap()
    var hud = MBProgressHUD()
    
 override func viewDidLoad() {
    super.viewDidLoad()
    
    // Go out back button this Bar Button
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    
    // Set BackGraund
    let bg = UIImage(named: "backWeather.jpg")
    self.view.backgroundColor = UIColor(patternImage: bg!)
    
    // Set setup
    self.openWeather.delegate = self
    
    locationManager.delegate = self
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    
    locationManager.startUpdatingLocation()

 }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addCity(_ sender: UIBarButtonItem) {
        displayCity() 
    }
    
    func displayCity() {
        
        let alert = UIAlertController(title: "City", message: "Enter name city", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            (action) -> Void in
            
            if let textField = alert.textFields?.first as UITextField? {
                self.activityIndicator()
                self.openWeather.weatherFor(city: textField.text!)
                
            }
        }
        
        alert.addAction(ok)
        
        alert.addTextField { (textField) in
            textField.placeholder = "City name"
        }
            
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func activityIndicator() {
        
        hud.labelText = "Loading..."
        hud.dimBackground = true
        self.view.addSubview(hud)
        hud.show(animated: true)
    }
    
    //MARK: OpenWeatherMapDelegat
    
    func updateWeatherInfo(weatherJson: JSON) {
        
        hud.hide(animated: true)
        
        print(weatherJson)
    
        if let tempResult = weatherJson["list"] [0] ["main"] ["temp"].double {
            
            // Get Country
            let country = weatherJson["city"] ["country"].stringValue
            
            // Get Name City
            let cityName = weatherJson["city"] ["name"].stringValue
            self.cityNameLabel.text = "\(cityName), \(country)"
            
            // Get time
            let now = Int(NSDate().timeIntervalSince1970)
            let time = weatherJson["list"] [0] ["dt"].intValue
            let timeToStr = openWeather.timeFromUnix(unixTime: now)
            self.timeLabel.text = "At \(timeToStr) it is"
            
            // Get convert Temperature
            let temperature = openWeather.convertTemperature(country: country, temperature: tempResult)
            self.tempLabel.text = "\(temperature)º"
            
            // Get icon
            let weather = weatherJson["list"] [0] ["weahter"] [0]
            let condition = weather["id"].intValue
            let iconStr = weather["icon"].stringValue
            let nightTime = openWeather.isTimeNight(icon: iconStr)
            openWeather.updateweatherIcon(condition: condition, nightTime: nightTime, index: 0, weatherIcon: self.updateIconList)
            
            // Get description
            let desc = weather["description"]["list"].stringValue
            self.descriptionLabel.text = "\(desc)"
            if desc != nil {
                self.descriptionLabel.text = "No Information"
            }
            
            //Get Wind Speed
            let speed = weatherJson["list"] [0] ["wind"] ["speed"].doubleValue
            self.speedWindLabel.text = "\(speed)"
            
            // Get Humidity
            let humidity = weatherJson["list"] [0] ["main"] ["humidity"].intValue
            self.humidityLabel.text = "\(humidity)"
            
            for index in 1...4 {
                
                if let tempResult = weatherJson["list"] [index] ["main"] ["temp"].double {
                    
                    //Get convert Temperature
                    let temperature = openWeather.convertTemperature(country: country, temperature: tempResult)
                    
                    if (index == 1) {
                        temp1Text = "\(temperature)"
                    } else if (index == 2) {
                        temp2Text = "\(temperature)"
                    } else if (index == 3) {
                        temp3Text = "\(temperature)"
                    }else if (index == 4) {
                        temp4Text = "\(temperature)"
                    }
                    
                    //Get forecast Time
                    let forecastTime = weatherJson["list"] [index] ["dt"].intValue
                    let timeToStr = openWeather.timeFromUnix(unixTime: Int(forecastTime))
                
                    if (index == 1) {
                        time1Text = timeToStr
                    } else if (index == 2) {
                        time2Text = timeToStr
                    } else if (index == 3) {
                        time3Text = timeToStr
                    } else if (index == 4) {
                        time4Text = timeToStr
                    }
                    
                    let weather = weatherJson["list"] [index] ["weahter"] [0]
                    let condition = weather["id"].intValue
                    let iconStr = weather["icon"].stringValue
                    let nightTime = openWeather.isTimeNight(icon: iconStr)
                    openWeather.updateweatherIcon(condition: condition, nightTime: nightTime, index: index, weatherIcon: self.updateIconList)
                }
            }
            
        } else {
            print("Error load weather info")
        }
    }
    
    func updateIconList(index: Int, name: String) {
        if (index == 0) {
            self.iconImageView.image = UIImage(named: name)
            
        }
        if (index == 1) {
            self.icon1 = UIImage(named: name)
        }
        if (index == 2) {
            self.icon2 = UIImage(named: name)
        }
        if (index == 3) {
            self.icon3 = UIImage(named: name)
        }
        if (index == 4) {
            self.icon4 = UIImage(named: name)
        }

        
    }
    
    func failure() {
        
        //No connection internet
        let networkController = UIAlertController(title: "Error", message: "No connection!", preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        networkController.addAction(okButton)
        
        self.present(networkController, animated: true, completion: nil)
        
        hud.hide(animated: true)

        
    }
    
    //MARK: -CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(manager.location!)
        
        self.activityIndicator()
        let currentLocation = locations.last! as CLLocation
        
            if(currentLocation.horizontalAccuracy > 0) {
                
        // Stop updating location to save battery life
        locationManager.stopUpdatingLocation()
                
        let coords = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        self.openWeather.weatherFor(geo :coords)
            print(coords)
                
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        print("Can't get your location")
    }
    
    //MARK: -prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInfo" {
            
            let forecastController = segue.destination as! ForecastViewController
            
            forecastController.time1 = self.time1Text
            forecastController.time2 = self.time2Text
            forecastController.time3 = self.time3Text
            forecastController.time4 = self.time4Text
            
            forecastController.icon1Image = self.icon1
            forecastController.icon2Image = self.icon2
            forecastController.icon3Image = self.icon3
            forecastController.icon4Image = self.icon4
            
            forecastController.temp1 = self.temp1Text
            forecastController.temp2 = self.temp2Text
            forecastController.temp3 = self.temp3Text
            forecastController.temp4 = self.temp4Text
            
        }
    }
 }
