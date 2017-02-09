//
//  BeaconInfo.swift
//  BleDemo
//
//  Created by Alex on 10/21/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import CoreLocation

let GROUP_NAME_CURRENT_BEACON = "group.com.app.kaushik.currentbeacon"
let GROUP_CURRENT_BEACON_UUID = "CurrentBeaconUUID"
let GROUP_CURRENT_BEACON_RSSI = "CurrentBeaconRSSI"
let GROUP_CURRENT_BEACON_NUMBERS = "CurrentBeaconNumbers"
let GROUP_CURRENT_BEACON_PAIR = "CurrentBeaconPair"
let GROUP_SIGNAL_IB = "SingalIB"
let GROUP_SIGNAL_UB = "SingalUB"

/// The beacon information store class. This class has each beacon's info values.
class BeaconInfo: NSObject, NSCoding {

    ///  beacon's UUID.
    var uuid: String = ""
    
    ///  beacon's major.
    var major: String = ""
    
    ///  beacon's minor.
    var minor: String = ""
    
    ///  beacon's identifier.
    var identifier: String = ""
    
    ///  beacon's rssi value.
    var rssi: Int = 0
    
    ///  beacon's number of signals.
    var numberofsignals: Int = 0
    
    ///  beacon's region.
    var beaconRegion: CLBeaconRegion? = nil

    ///  init method.
    public required init (uuid:String, major:String, minor:String, identifier:String) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.identifier = identifier
    }
    
    ///  decode method for class member.
    public required init?(coder aDecoder: NSCoder) {
        
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as? String ?? ""
        self.major = aDecoder.decodeObject(forKey: "major") as? String ?? ""
        self.minor = aDecoder.decodeObject(forKey: "minor") as? String ?? ""
        self.identifier = aDecoder.decodeObject(forKey: "identifier") as? String ?? ""
        self.rssi = aDecoder.decodeInteger(forKey: "rssi")
        self.numberofsignals = aDecoder.decodeInteger(forKey: "numberofsignals")
        self.beaconRegion = aDecoder.decodeObject(forKey: "beaconRegion") as! CLBeaconRegion?
    }

    ///  encode method for class member.
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(rssi, forKey: "rssi")
        aCoder.encode(numberofsignals, forKey: "numberofsignals")
        aCoder.encode(beaconRegion, forKey: "beaconRegion")
    }
}
