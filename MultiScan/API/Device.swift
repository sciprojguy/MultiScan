//
//  Device.swift
//  MultiScan
//
//  Created by Chris Woodard on 7/2/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import Foundation

struct Device: Codable {
    var deviceName: String
    var deviceType: String
    var deviceOS: String
    var deviceToken:String
    var appId:String
    func json() -> [String:Any] {
        return ["deviceName" : deviceName, "deviceType" : deviceType, "deviceOS" : deviceOS, "deviceToken" : deviceToken, "appId" : appId]
    }
}
