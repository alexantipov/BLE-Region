//
//  TodayViewController.swift
//  BleStatusTodayExtension
//
//  Created by Alex on 11/13/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var labelUUID: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
        
    @IBOutlet weak var labelStatus: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        ///   create time schedule
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(self.updateTime),
                             userInfo: nil,
                             repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
//        // Perform any setup necessary in order to update the view.
//        
//        // If an error is encountered, use NCUpdateResult.Failed
//        // If there's no update required, use NCUpdateResult.NoData
//        // If there's an update, use NCUpdateResult.NewData
//        
//        completionHandler(NCUpdateResult.newData)
//    }
    
    ///  update the cotent of widget
    func updateTime() {
        
        ///  get current time
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        ///  get beacon info from group storage with CURRENT_PAIRED_BEACON.
        if let userDefaults = UserDefaults(suiteName:GROUP_NAME_CURRENT_BEACON) {
            
            var uuid : String = ""
            var rssi : Int = 0
            var numbers : Int = 0
            var pairedBeacon : Bool = false
            
            labelStatus.isHidden = true
            labelUUID.isHidden = true
            labelDetails.isHidden = true

            ///  get Beacon's info.
            if let pairedBeaconTemp = userDefaults.value(forKey: GROUP_CURRENT_BEACON_PAIR) {
                pairedBeacon = pairedBeaconTemp as! Bool
            }
            
            if pairedBeacon == false {
                
                labelStatus.isHidden = false
                
                labelStatus.text = "There is no the paired beacon."
                
                self.view.backgroundColor = UIColor.gray
                
                return
            }
            
            ///  get uuid
            if let uuidTemp = userDefaults.value(forKey: GROUP_CURRENT_BEACON_UUID) {
                uuid = uuidTemp as! String
            }
            ///  get rssi value
            if let rssiTemp = userDefaults.value(forKey: GROUP_CURRENT_BEACON_RSSI) {
                rssi = rssiTemp as! Int
            }
            
            ///  get number of signals
            if let numbersTemp = userDefaults.value(forKey: GROUP_CURRENT_BEACON_NUMBERS) {
                numbers = numbersTemp as! Int
            }
            
            ///  change status bar color
            changeStatusBarColor (rssi: rssi)
            
            if rssi == 0 {
                ///  show beacon's info
                labelStatus.isHidden = false
                
                labelStatus.text = "The paired beacon is not found."
                
                self.view.backgroundColor = UIColor.gray
            } else {
                
                labelUUID.isHidden = false
                labelDetails.isHidden = false

                ///  show beacon's info
                labelUUID.text = "UUID : " + uuid.uppercased()

                labelDetails.text = "rssi : " + String(rssi) + ", numbers of signal : " + String(numbers) + ", time : " + String(format: "%02d:%02d:%02d", hour, minutes, seconds)
            }
        }
    }
    
    ///  update background color according to rssi value
    func changeStatusBarColor (rssi : Int) {
        
        var ib : Int = 50
        var ub : Int = 50
        
        if let userDefaults = UserDefaults(suiteName:GROUP_NAME_CURRENT_BEACON) {

            if let numbers = userDefaults.value(forKey: GROUP_SIGNAL_IB) {
                let numbersString = numbers as! String
                ib = Int(numbersString)!
            }
            
            if let numbers = userDefaults.value(forKey: GROUP_SIGNAL_UB) {
                let numbersString = numbers as! String
                ub = Int(numbersString)!
            }
        }

        if abs(rssi) > abs(ib) {
            
            self.view.backgroundColor = UIColor.black
            self.labelUUID.textColor = UIColor.white
            self.labelDetails.textColor = UIColor.white
            
        } else if abs(rssi) < abs(ub) && abs(rssi) > 0 {
            
            self.view.backgroundColor = UIColor.green
            self.labelUUID.textColor = UIColor.black
            self.labelDetails.textColor = UIColor.black
            
        }
    }
}
