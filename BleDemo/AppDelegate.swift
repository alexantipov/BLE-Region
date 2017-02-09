//
//  AppDelegate.swift
//  BleDemo
//
//  Created by Alex on 10/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import UserNotifications
import CoreBluetooth
import CoreMotion

import Fabric
import Crashlytics

let BUGFENDERSDK_KEY = "app_key"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CBCentralManagerDelegate {

    var window: UIWindow?

    private var centralManager: CBCentralManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self])

        ///  Allows the drop down to display correctly when keyboard is showed.
        DropDown.startListeningToKeyboard()
        
        ///  check the motion activity is not idel...
        checkMotionActivity();
        
        ///  Start beacon region
        startupBeaconRegionsFromLocalData ()
        
        ///   create time schedule
        Timer.scheduledTimer(timeInterval: 60 * 2,  //2 minutes
                             target: self,
                             selector: #selector(self.checkAppSettingTime),
                             userInfo: nil,
                             repeats: true)
        
        ///  remote log
        Bugfender.activateLogger(BUGFENDERSDK_KEY)
        Bugfender.enableNSLogLogging()
        
        BFLog("#######################################")
        BFLog("###      BugfenderSDK - BLE Demo    ###")
        BFLog("#######################################")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        BFLog("App is going to background!")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        
        BFLog("App is coming from background to active!")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    ///  start beacons' reation from local storage
    func startupBeaconRegionsFromLocalData () {
        
        QL_LOG_INFO("Start beacons' region from the data of local storage")
        
        if let pair = UserDefaults.standard.value(forKey: BEACON_PAIRED_MODE) {
            
            ///  set pair mode
            BeaconRegionManager.pairedMode = PairedMode(rawValue: pair as! Int)!

            ///  set foundOnlyOneBeacon for the PairedMode
            if BeaconRegionManager.pairedMode == PairedMode.PAIR_DEVICE {
                
                BeaconRegionManager.foundOnlyOneBeacon = false
                
                ///  get beacons from local storage with LOCAL_STORAGE_BEACON_LIST.
                if let placeData = UserDefaults.standard.value(forKey: LOCAL_STORAGE_BEACON_LIST) {
                    
                    ///  get Beacons array.
                    BeaconRegionManager.arrayBeaconList = (NSKeyedUnarchiver.unarchiveObject(with: placeData as! Data) as? NSMutableArray)!
                    
                    ///  start all beacons.
                    BeaconRegionManager.startAllBeacons()
                }
                
            } else {
                
                return
            }
        }
    }
    
    ///  check app settings every two minutes
    func checkAppSettingTime () {
        
        ///  check BLE is turned on
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        
        
        if let pair = UserDefaults.standard.value(forKey: BEACON_PAIRED_MODE) {
            
            ///  get pair mode
            let pairedMode:PairedMode = PairedMode(rawValue: pair as! Int)!
            
            ///  if we can't signal
            if pairedMode == PairedMode.PAIR_DEVICE && BeaconRegionManager.activatedBeacons == false{
                
//                BeaconRegionManager.pairedMode = PairedMode.NONE
//                
//                UserDefaults.standard.setValue(BeaconRegionManager.pairedMode.rawValue, forKey: BEACON_PAIRED_MODE)
                
                BeaconRegionManager.stopAllBeaconsRegion()
            }
        }
        
        checkMotionActivityAndBluetooth ()
    }
    
    ///  show alert to set the bluetooth
    func alertBluetooth () {
        
        let alert = UIAlertController(title: "Turn On Bluetooth to Allow app to Connect to Accessories", message: "", preferredStyle: .alert)
        
        //  Go to Settings->Bluetooth when the user clicks Setting.
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
            
            let instanceOfSettingsManage = SettingsManage()
            instanceOfSettingsManage.opneSettings()
     
        }))
        
        //  Present the alert.
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)

    }
    

    //==========================================================================================================
    // MARK: - CBCentralManagerDelegate Methods
    //==========================================================================================================
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if #available(iOS 10.0, *) {
            
            switch (central.state) {
            case CBManagerState.poweredOff:
                print("Power off")
                
                break
            case CBManagerState.unauthorized:
                print("Unauthorized")
                // Indicate to user that the iOS device does not support BLE.
                break
                
            case CBManagerState.unknown:
                print("Unknown")
                // Wait for another event
                break
                
            case CBManagerState.poweredOn:
                print("Powered on")
                
                let navigationController = self.window?.rootViewController as! UINavigationController
                let viewController = navigationController.viewControllers[0] as! MainViewController
                viewController.checkStartupPassword()
                
                return
                
            case CBManagerState.resetting:
                print("resetting")
                break
                
            case CBManagerState.unsupported:
                print("unsupported")
                break
            }
            
        } else {

        }
        
        alertBluetooth()
    }
    
    
    private func checkMotionActivity () {
        
        
        if CMMotionActivityManager.isActivityAvailable() {

            let motionActivityManager = CMMotionActivityManager()

            motionActivityManager.startActivityUpdates(to: OperationQueue.current!, withHandler: {
                activityData
                in
                
                print(activityData!)
                if activityData!.stationary == false || activityData!.unknown == true {
                    
                    motionActivityManager.stopActivityUpdates()
                    self.alertBluetooth();
                }
                
            })
        }
    }
    
    private func checkMotionActivityAndBluetooth () {
        
        
        if CMMotionActivityManager.isActivityAvailable() {
            
            let motionActivityManager = CMMotionActivityManager()
            
            motionActivityManager.startActivityUpdates(to: OperationQueue.current!, withHandler: {
                activityData
                in
                
                print(activityData!)
                if activityData!.stationary == false || activityData!.unknown == true {
                    
                    if (self.centralManager?.state != CBManagerState.poweredOn) {
                        motionActivityManager.stopActivityUpdates()
                        self.alertBluetooth();
                    }
                }
                
            })
        }
    }

}

