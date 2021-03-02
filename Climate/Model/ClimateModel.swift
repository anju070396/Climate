//
//  climateModel.swift
//  Climate
//
//  Created by Anjali on 28/2/21.
//

import Foundation

class ClimateModel {
     var cityName : String
     var temperature : String
     var climateName : String
    
    init(cityName: String,temperature: String,climateName: String  ) {
        self.cityName =  cityName
        self.temperature = temperature
        self.climateName = climateName
    }
}
