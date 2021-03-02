//
//  Constant.swift
//  Climate
//
//  Created by Anjali on 1/3/21.
//

import Foundation

extension UserDefaults {
   
    enum Keys {
        static let fouriteList = "fouriteList"
    }
    
    func saveValueLocally(value : Any, for key : String ) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
}


class Constant {
    
}
