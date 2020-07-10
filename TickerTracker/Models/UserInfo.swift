//
//  UserInfo.swift
//  TickerTrackr
//
//  Created by Slava Pashaliuk on 7/9/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation

class UserInfo: NSObject, NSCoding {
    var name: String
    var bottom: Double
    var top: Double
    
    init(name: String, bottom: Double, top: Double) {
        self.name = name
        self.bottom = bottom
        self.top = top
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let bottom = aDecoder.decodeDouble(forKey: "bottom")
        let top = aDecoder.decodeDouble(forKey: "top")
        self.init(name: name, bottom: bottom, top: top)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(bottom, forKey: "bottom")
        aCoder.encode(top, forKey: "top")
    }
}
