//
//  MMOpenWeatherMap.swift
//  My WetherMap
//
//  Created by Марк Моторя on 19.12.16.
//  Copyright © 2016 Motorya Mark. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire

protocol OpenWeatherMapDelegate {
    
    func updateWeatherInfo(weatherJson: JSON)
    func failure()
}

class MMOpenWeatherMap {
    
    let weatherUrl = "http://api.openweathermap.org/data/2.5/forecast?&APPID=7601f2b623606b1a51047ff0c268e7bf"
    
    var delegate: OpenWeatherMapDelegate!
    
    func weatherFor(city : String) {
        
        let params = ["q" : city]
        
        setRequest(params: params as [String : AnyObject]?)
        
    }
    
    func weatherFor(geo: CLLocationCoordinate2D) {
        let params = ["lat": geo.latitude, "lon": geo.longitude]
        setRequest(params: params as [String : AnyObject]?)
        
    }
    
    func setRequest(params: [String: AnyObject]?) {
        
        Alamofire.request(weatherUrl, method: .get, parameters: params).responseJSON { response -> Void in
            
            if ((response.result.error) != nil) {
                self.delegate.failure()
            } else {
            
            let weatherJson = JSON(response.result.value!)
            
            DispatchQueue.main.async { [weak self] () -> Void in
                self?.delegate.updateWeatherInfo(weatherJson: weatherJson)
                
            }
        }
    }
}
    
    func timeFromUnix(unixTime: Int) -> String {
        let timeInSecond = TimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSecond)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: weatherDate as Date)
    }
    
    func updateweatherIcon(condition: Int, nightTime: Bool, index: Int, weatherIcon: (_ index: Int, _ icon: String) ->()) {
        
        switch (condition, nightTime) {
            
                // Tunderstorm
            case let (x,y) where x < 300 && y == true: weatherIcon(index, "11n")
            case let (x,y) where x < 300 && y == false: weatherIcon(index, "11d")
                // Drizzle
            case let (x,y) where x < 500 && y == true: weatherIcon(index, "09n")
            case let (x,y) where x < 500 && y == false: weatherIcon(index, "09d")
                // Rain
            case let (x,y) where x <= 504 && y == true: weatherIcon(index, "10n")
            case let (x,y) where x <= 504 && y == false: weatherIcon(index, "10d")
            
            case let (x,y) where x == 511 && y == true: weatherIcon(index, "13n")
            case let (x,y) where x == 511 && y == false: weatherIcon(index, "13d")
            
            case let (x,y) where x < 600 && y == true: weatherIcon(index, "09n")
            case let (x,y) where x < 600 && y == false: weatherIcon(index, "09d")
                // Snow
            case let (x,y) where x < 700 && y == true: weatherIcon(index, "13n")
            case let (x,y) where x < 700 && y == false: weatherIcon(index, "13d")
                // Atmosphere
            case let (x,y) where x < 800 && y == true: weatherIcon(index, "50n")
            case let (x,y) where x < 800 && y == false: weatherIcon(index, "50d")
                // Clouds
            case let (x,y) where x == 800 && y == true: weatherIcon(index, "01n")
            case let (x,y) where x == 800 && y == false: weatherIcon(index, "01d")
            
            case let (x,y) where x == 801 && y == true: weatherIcon(index, "02n")
            case let (x,y) where x == 801 && y == false: weatherIcon(index, "02d")
            
            case let (x,y) where x > 802 || x < 804 && y == true: weatherIcon(index, "03n")
            case let (x,y) where x > 802 || x < 804 && y == false: weatherIcon(index, "03d")
            
            case let (x,y) where x == 804 && y == true: weatherIcon(index, "04n")
            case let (x,y) where x == 804 && y == false: weatherIcon(index, "04d")
                // Additional
            case let (x,y) where x < 1000 && y == true: weatherIcon(index, "11n")
            case let (x,y) where x < 1000 && y == false: weatherIcon(index, "11d")
            
        case (_, _): weatherIcon(index, "none")

        }
    }
    
    func convertTemperature(country: String, temperature: Double) -> Double {
        if (country == "US") {
            // Converted to Faringat
            return round(((temperature - 273.15) * 1.8) + 32)
        } else {
            // Converted to Celsiy
            return round(temperature - 273.15)
            
        }
    }
    
    func isTimeNight(icon: String) -> Bool {
        return (icon.range(of: "n") != nil)
        
    }
}
