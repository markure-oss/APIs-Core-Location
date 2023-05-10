//
//  WeatherManager.swift
//  Clima
//
//  Created by HungPham on 2023/04/28.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

 

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=940393133c64c829d05f26bc869a4079&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName : String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latidute: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latidute)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    // nap du lieu JSON tu API weather.map
    func performRequest(with urlString: String) {
            //1. create  a url
        if let url = URL(string: urlString) {
            //2. create a url secssion
            let session = URLSession(configuration: .default)
            //3. give a secssion a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4. stask the task
            task.resume()
        }
    }
    
    //phân tích dữ liệu từ định dạng của Json
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
