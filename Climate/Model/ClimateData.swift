//
//  ClimateModel.swift
//  Climate
//
//  Created by Anjali on 28/2/21.
//

import Foundation

struct ClimateData : Codable {
    let name : String
    let main : Main
    let weather : [Weather]
}

struct Main :Codable {
    let temp : Double
}

struct Weather : Codable {
    let id : Int
    let description : String
}
