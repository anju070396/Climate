//
//  ViewController.swift
//  Climate
//
//  Created by Anjali on 27/2/21.
//

import UIKit
import CoreLocation
import Connectivity


class ClimateViewController: UIViewController, ClimateDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityNameSearchTextField : UITextField!
    @IBOutlet weak var cityNameLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var tempLable : UILabel!
    @IBOutlet weak var climateImage : UIImageView!
    
    let net = NetServices()
    var locationManager:CLLocationManager!
    let connectivity: Connectivity = Connectivity()

    override func viewDidLoad() {
        super.viewDidLoad()
        net.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.dateLabel.text = getCurrentDate()!
    }
    
    func serachClimateByCityName() {
        cityNameSearchTextField.endEditing(true)
    }
    
    func didUpdateClimate(climate: ClimateModel) {
        print(climate.temperature)
        if let arr = UserDefaults.standard.object(forKey: UserDefaults.Keys.fouriteList) as? [[String: String]] {
            print("data stored", arr[0])
        } else {
            print("data stored failed")
        }
        DispatchQueue.main.async {
            self.cityNameLabel.text = climate.cityName
            self.climateImage.image = UIImage(systemName: climate.climateName)
            self.convertTempStringIntoDegree(temp:  climate.temperature)
        }
    }
    
    func didFailedWithError(error: Error) {
        print(error)
        DispatchQueue.main.async {
            if let data = self.checkForPreviousData(cityName : self.cityNameSearchTextField.text!) {
                self.cityNameLabel.text = data.first?.key
            } else {
//                DispatchQueue.main.async {
                    self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
//                }
            }
        }
    }
    func convertTempStringIntoDegree(temp : String) {
        let measurement = Measurement(value: Double(temp)!, unit: UnitTemperature.celsius)
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.maximumFractionDigits = 0
        measurementFormatter.unitOptions = .temperatureWithoutUnit
        self.tempLable.text = measurementFormatter.string(from: measurement) + "C"
    }
    
    @IBAction func ShowFouriteList() {
        self.performSegue(withIdentifier: "goToFouriteList", sender: self)
    }
    
    func getCurrentDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "EEEE, d MMM yyyy"
        return dateFormatter.string(from: Date())
    }
    
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation

        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        self.locationManager.stopUpdatingLocation()
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in getting location")
                self.showAlert(with: "Sorry, Unable to fetch current location")
            } else {
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count>0{
                    let placemark = placemarks![0]
                    print(placemark.locality!)
                    print(placemark.administrativeArea!)
                    print(placemark.country!)
                    
                    self.connectivity.checkConnectivity { connectivity in

                        switch connectivity.status {
                        case .connected:
                            self.net.getClimateData(cityName: placemark.locality!)
                            break
                        case .connectedViaWiFi:
                            self.net.getClimateData(cityName: placemark.locality!)
                            break
                        case .connectedViaWiFiWithoutInternet:
                            if let data = self.checkForPreviousData(cityName: self.cityNameSearchTextField.text!) {
                                self.cityNameLabel.text = data.first?.key
                                self.convertTempStringIntoDegree(temp: data.first!.value)
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                                }
                            }
                            break
                        case .connectedViaCellular:
                            self.net.getClimateData(cityName: placemark.locality!)
                            break
                        case .connectedViaCellularWithoutInternet:
                            if let data = self.checkForPreviousData(cityName: self.cityNameSearchTextField.text!) {
                                self.cityNameLabel.text = data.first?.key
                                self.convertTempStringIntoDegree(temp: data.first!.value)
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                                }
                            }
                            break
                        case .notConnected:
                            if let data = self.checkForPreviousData(cityName:self.cityNameSearchTextField.text! ) {
                                self.cityNameLabel.text = data.first?.key
                                self.convertTempStringIntoDegree(temp: data.first!.value)
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                                }
                            }
                            break
                        case .determining:
                            if let data = self.checkForPreviousData(cityName: self.cityNameSearchTextField.text!) {
                                self.cityNameLabel.text = data.first?.key
                                self.convertTempStringIntoDegree(temp: data.first!.value)
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                                }
                            }
                            break
                        }
                    }
                }
            }
        }
    }
    
    func checkForPreviousData(cityName : String) -> [String:String]? {
        if let fouriteList = UserDefaults.standard.object(forKey: UserDefaults.Keys.fouriteList) as? [[String : String]] {
            for dic in fouriteList{
                if dic.first?.key == cityName {
                    return dic
                }
            }
        }
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        
    }
    
    func showAlert(with message : String) {
        let alert = UIAlertController(title: "Climate", message : message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}


extension ClimateViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cityName = cityNameSearchTextField.text {
            if cityName.isEmpty {
                showAlert(with: "Please enter city name")
            } else {
                connectivity.checkConnectivity { connectivity in
                    
                    switch connectivity.status {
                    case .connected:
                        self.net.getClimateData(cityName: cityName)
                        break
                    case .connectedViaWiFi:
                        self.net.getClimateData(cityName: cityName)
                        break
                    case .connectedViaWiFiWithoutInternet:
                        print("No internet wifi")
                        if let data = self.checkForPreviousData(cityName: self.cityNameSearchTextField.text!) {
                            self.cityNameLabel.text = data.first?.key
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                            }
                        }
                        break
                    case .connectedViaCellular:
                        self.net.getClimateData(cityName: cityName)
                        break
                    case .connectedViaCellularWithoutInternet:
                        if let data = self.checkForPreviousData(cityName: self.cityNameSearchTextField.text!) {
                            self.cityNameLabel.text = data.first?.key
                            self.convertTempStringIntoDegree(temp: data.first!.value)
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                            }
                        }
                        print("No internet")
                        break
                    case .notConnected:
                        if let data = self.checkForPreviousData(cityName: self.cityNameSearchTextField.text!) {
                            self.cityNameLabel.text = data.first?.key
                            self.convertTempStringIntoDegree(temp: data.first!.value)
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                            }
                        }
                        print("notConnected")
                        break
                    case .determining:
                        if let data = self.checkForPreviousData(cityName: self.cityNameSearchTextField.text!) {
                            self.cityNameLabel.text = data.first?.key
                            self.convertTempStringIntoDegree(temp: data.first!.value)
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(with: "Sorry, Unable to find \(self.cityNameSearchTextField.text!) you entered")
                            }
                        }
                        print("Determine")
                        break
                    }
                }
            }
        }
    }
}
