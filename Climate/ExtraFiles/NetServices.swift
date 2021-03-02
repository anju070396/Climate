//
//  NetServices.swift
//  Climate
//
//  Created by Anjali on 27/2/21.
//

import Foundation


protocol ClimateDelegate {
    func didUpdateClimate(climate: ClimateModel)
    func didFailedWithError(error: Error)
}


class NetServices {
    
    var delegate : ClimateDelegate?
    
    func getClimateData(cityName : String) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?appid=b286feef8cdfc54a65764f954b9dc228&units=metric&q="
        
        let climateURL = "\(urlStr)\(cityName)"
        print(climateURL)
        
        if let url = URL(string: climateURL) {
            
            let urlSession = URLSession(configuration: .default)
            
            let urlTask = urlSession.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailedWithError(error: error!)
                    return
                }
                
                if let responseData = data {
                    
                    let decoder = JSONDecoder()
                    do {
                        let decodedData = try decoder.decode(ClimateData.self, from: responseData)
                        let name = decodedData.name
                        let temp = decodedData.main.temp
                        let id = decodedData.weather[0].id
                        
                         var climateName: String {
                            switch id {
                            case 200...232:
                                return "cloud.bolt"
                            case 300...321:
                                return "cloud.drizzle"
                            case 500...531:
                                return "cloud.rain"
                            case 600...622:
                                return "cloud.snow"
                            case 701...781:
                                return "cloud.fog"
                            case 800:
                                return "sun.max"
                            case 801...804:
                                return "cloud.bolt"
                            default:
                                return "cloud"
                            }
                        }
                        
                        var temperatureString : String {
                            return String(format: "%.1F", temp)
                        }
        
                        let climate = ClimateModel(cityName: name, temperature: temperatureString, climateName: climateName)
                        var fouriteList = [[String:String]]()
                       
                        if let previousFouriteList = UserDefaults.standard.object(forKey: UserDefaults.Keys.fouriteList) as? [[String: String]] {
                            fouriteList = self.checkCurrentCityAvailableInLocal(previousFouriteList: previousFouriteList, currentCity: cityName)
                            fouriteList.append([cityName : temperatureString])
                            UserDefaults.standard.saveValueLocally(value: fouriteList, for: UserDefaults.Keys.fouriteList)
                    } else {
                            fouriteList.append([cityName : temperatureString])
                            UserDefaults.standard.saveValueLocally(value: fouriteList, for: UserDefaults.Keys.fouriteList)
                        }
                        self.delegate?.didUpdateClimate(climate: climate)
                    } catch {
                        print(error)
                        self.delegate?.didFailedWithError(error: error)
                    }
                }
            }
            urlTask.resume()
        }
    }
    
    func checkCurrentCityAvailableInLocal(previousFouriteList : [[String: String]], currentCity : String) -> [[String:String]] {
        var finalFouriteList =  [[String : String]]()
            finalFouriteList = previousFouriteList
            for (index,dic) in previousFouriteList.enumerated() {
                if dic.first?.key == currentCity {
                    finalFouriteList.remove(at: index)
                }
            }
        return finalFouriteList
    }
}
