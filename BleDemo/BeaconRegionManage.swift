//
//  BeaconRegionManage.swift
//  BleDemo
//
//  Created by Alex on 10/21/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

let LOCAL_STORAGE_BEACON_LIST = "BeaconList"
let BEACON_PAIRED_MODE = "PairedMode"

/// management class for all beacon
class BeaconRegionManage: NSObject {
    
    ///  static instance for this class.
    static let sharedBeaconRegionManage = BeaconRegionManage()
    
    ///  beacon array for each beacon info (BeaconInfo class).
    var arrayBeaconList:NSMutableArray = []
    
    ///  signal array for each beacon info (BeaconInfo class).
    var arraySignalList:NSArray = []

    ///  create location service.
    let locationManager = CLLocationManager()
    
    ///  intially set pair mode to none.
    var pairedMode:PairedMode = PairedMode.NONE
    
    ///  use for one pair mode.
    var foundOnlyOneBeacon:Bool = false
    
    ///  turu if there are acitivated beacons.
    var activatedBeacons:Bool = true

    
    //==========================================================================================================
    // MARK: - Public Methods
    //==========================================================================================================

    ///  start all beacons' region.
    func startAllBeacons () {
        
        QL_LOG_INFO("Starting all beacons' region...")
        
        ///  set CLLocationManagerDelegate.
        self.locationManager.delegate = self
        
        ///  prevent that location updates may automatically be paused when possible.
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
        ///  allow background location updates.
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        ///  the desired location accuracy.
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        ///  Whenever we move.
        self.locationManager.distanceFilter = kCLDistanceFilterNone

        ///  start all beacons' region.
        for beaconInfo in self.arrayBeaconList {
            
            ///  get a beacon from BeaconInfo
            let uuidString = (beaconInfo as! BeaconInfo).uuid.uppercased()
            let beaconIdentifier = (beaconInfo as! BeaconInfo).identifier
            let beaconUUID:UUID = UUID(uuidString: uuidString)!
            
            ///  create a beacon's region.
            let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
                                                         identifier: beaconIdentifier)
            
            ///  save a beacon region for stopping after.
            (beaconInfo as! BeaconInfo).beaconRegion = beaconRegion

            ///  start monitoring the specified region.
            self.locationManager.startMonitoring(for: beaconRegion)
            
            ///  start calculating ranges for beacons in the specified region.
            self.locationManager.startRangingBeacons(in: beaconRegion)
        }
        
        ///  request always authorization for location.
        if(self.locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
            self.locationManager.requestAlwaysAuthorization()
        }

        ///  start updating locations.
        self.locationManager.startUpdatingLocation()
        
        QL_LOG_INFO("Started all beacons' region")
    }
    
    ///  stop all beacons' region.
    func stopAllBeacons () {
        
        QL_LOG_INFO("Stopping all beacons' region...")

        ///  for all beacons.
        for beacon in self.arrayBeaconList {
            
            if (beacon as! BeaconInfo).beaconRegion != nil {
                ///  stop calculating ranges for the specified region.
                self.locationManager.stopRangingBeacons(in: (beacon as! BeaconInfo).beaconRegion!)
                
                ///  stop monitoring the specified region.
                self.locationManager.stopMonitoring(for: (beacon as! BeaconInfo).beaconRegion!)
            }
        }
        
        ///  stop updating locations.
        self.locationManager.stopUpdatingLocation()
        
        QL_LOG_INFO("Stopped all beacons' region")
    }
    
    
    ///  stop all beacons' region.
    func stopAllBeaconsRegion () {
        
        QL_LOG_INFO("Stopping all beacons' region...")
        
        ///  for all beacons.
        for beacon in self.arrayBeaconList {
            
            if (beacon as! BeaconInfo).beaconRegion != nil {
                ///  stop calculating ranges for the specified region.
                self.locationManager.stopRangingBeacons(in: (beacon as! BeaconInfo).beaconRegion!)
                
            }
        }
        
        QL_LOG_INFO("Stopped all beacons' region")
    }
    
    
    ///  stop other beacons except of specified a beacon.
    func stopBeacons (beacon:CLBeacon) {
        
        QL_LOG_INFO("Stop other beacons except of specifided beacon")

        ///  get a specified BeaconInfo object from beacons array.
        let sameBeacon = getEqualCLBeacon(beacon: beacon)
        	
        for beacon in self.arrayBeaconList {
            
            ///  ignore if the specifided beacon.
            if sameBeacon == (beacon as! BeaconInfo) {
                continue
            }
            
            ///  stop calculating ranges for the specified region.
            self.locationManager.stopRangingBeacons(in: (beacon as! BeaconInfo).beaconRegion!)
        }
    }
}


//==========================================================================================================
// MARK: - CLLocationManagerDelegate Methods
//==========================================================================================================

extension BeaconRegionManage: CLLocationManagerDelegate {
    
    ///  invoked when the user enters a monitored region.
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        
        QL_LOG_INFO("You entered the region")
        
        activatedBeacons = true
  
        ///  start calculating ranges for beacons in the specified region.
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        
        let beaconRegion = region as! CLBeaconRegion
        
        if !isExistBeacon(beacon: beaconRegion.proximityUUID.uuidString.uppercased()) {
            
            return
        }

        ///  trigger local notification.
        let message = "You entered the region"
        triggerLocalNotification (message: message)
        showMessage(message: message)
        
        /// send notification to server
        ApiManage.sharedApiManage.sendBeconRegionMessageToServer(beconUDID: beaconRegion.proximityUUID.uuidString.uppercased(), message: "entered zone")
    }
    
    ///  invoked when the user exits a monitored region.
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
        
        QL_LOG_INFO("You exited the region")
        
        activatedBeacons = false
        
        ///  stop calculating ranges for the specified region.
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        
        let beaconRegion = region as! CLBeaconRegion

        if !isExistBeacon(beacon: beaconRegion.proximityUUID.uuidString.uppercased()) {
            
            return
        }

        ///  trigger local notification.
        let message = "You exited the region"
        triggerLocalNotification (message: message)
        showMessage(message: message)
        
        /// send notification to server
        ApiManage.sharedApiManage.sendBeconRegionMessageToServer(beconUDID: beaconRegion.proximityUUID.uuidString.uppercased(), message: "exited zone")
    }

    ///  invoked when a new set of beacons are available in the specified region.
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
    
        ///  it may be assumed no beacons that match the specified region are nearby.
        if beacons.count == 0 {
            
            return
        }
        
        QL_LOG_INFO("You are in didRangeBeacons")

        /// when the one pair mode, stop other beacons except of first beacon.
        if foundOnlyOneBeacon == false {
            
            QL_LOG_INFO("Stop other beacons...")

            foundOnlyOneBeacon = true
            
            ///  get first beacon.
            let nearestBeacon:CLBeacon = beacons[0]
            
            ///  stop other beacons except of specifided beacon.
            stopBeacons(beacon: nearestBeacon)
        }
        
        ///  for all beacons...
        for i in 0  ..< beacons.count  {
            
            QL_LOG_INFO("Proximity Beacon")

            ///  get a beacon.
            let nearestBeacon:CLBeacon = beacons[i]
            
            ///  contnue if the beacon is one of our beacons...
            if let searchedBeacon = getEqualCLBeacon(beacon: nearestBeacon) {
                
                QL_LOG_INFO("Beacon exists in our beacon array")

                let beaconInfo = searchedBeacon as BeaconInfo
                
                ///  set current beacon's rssi value.
                beaconInfo.rssi = nearestBeacon.rssi
                
                /// ignore if the beacon's rssi value has no...
                if nearestBeacon.rssi == 0 {
                    continue
                }
                ///println("Cat Years: \(catYears)")
                print(" beaconInfo.numberofsignals = : \(beaconInfo.numberofsignals)")
                print(" beaconInfo.rssi = : \(beaconInfo.rssi)")
              ///  QL_LOG_INFO(",String(beaconInfo.numberofsignals))
              ///  QL_LOG_INFO("rssi = ",String(beaconInfo.rssi))
                ///  increase the number of signals.
                beaconInfo.numberofsignals += 1
                
                ///  store current beacon info
                if let userDefaults = UserDefaults(suiteName:GROUP_NAME_CURRENT_BEACON) {
                    userDefaults.setValue(beaconInfo.uuid, forKey: GROUP_CURRENT_BEACON_UUID)
                    userDefaults.setValue(beaconInfo.rssi, forKey: GROUP_CURRENT_BEACON_RSSI)
                    userDefaults.setValue(beaconInfo.numberofsignals, forKey: GROUP_CURRENT_BEACON_NUMBERS)
                }
            }
        }
        
        ///  update ui's rssi value.
        if beacons.count > 0 {
            
            QL_LOG_INFO("Update beacon data")
            
            /// Store all beacons' values into local storage with LOCAL_STORAGE_BEACON_LIST
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: BeaconRegionManager.arrayBeaconList)
            UserDefaults.standard.set(encodedData, forKey: LOCAL_STORAGE_BEACON_LIST)
        }
    }
    
    ///  get same BeaconInfo object with sepcified beacon's uuid
    func getEqualCLBeacon(beacon:CLBeacon) -> BeaconInfo?{
        
        QL_LOG_INFO("Search same beacon")

        for beaconInfo in BeaconRegionManager.arrayBeaconList {
            
            if beacon.proximityUUID.uuidString.uppercased() == (beaconInfo as! BeaconInfo).uuid.uppercased() {
                
                return beaconInfo as? BeaconInfo
            }
        }

        return nil
    }
    
    ///  get same BeaconInfo object with sepcified beacon's uuid
    func isExistBeacon(beacon:String) -> Bool {
        
        QL_LOG_INFO("Search same beacon")
        
        for beaconInfo in BeaconRegionManager.arrayBeaconList {
            
            if beacon.uppercased() == (beaconInfo as! BeaconInfo).uuid.uppercased() {
                
                return true
            }
        }
        
        return false
    }

    
    ///  trigger local notification.
    func triggerLocalNotification (message:String) {
        
        QL_LOG_INFO("Trigger Local Notification")

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in}
            
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "BLE Demo", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1)
            content.categoryIdentifier = "com.bledemo.localNotification"
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest.init(identifier: "BLE_DEMO", content: content, trigger: trigger)
            center.add(request)

        } else {
            
            let localNotification = UILocalNotification()
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
            localNotification.alertBody = message
            localNotification.timeZone = NSTimeZone.default
            localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    
    func showMessage(message:String) {
        
        ///  show alert
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

}

///  global instance for this class.
let BeaconRegionManager = BeaconRegionManage.sharedBeaconRegionManage
