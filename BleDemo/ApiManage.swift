//
//  ApiManage.swift
//  BleDemo
//
//  Created by Alex on 10/21/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import Alamofire


///  server urls
let URL_GET_BEACONS_DATA = "https://foo1391jyi.execute-api.us-west-2.amazonaws.com/production/getallmacidbygroupinfo/UNL-V0/all"
let URL_POST_BEACON_DATA = "https://cc84c4p0t7.execute-api.us-west-2.amazonaws.com/production/persistdeviceinfo"
let URL_GET_SIGNAL_DATA = "https://sm8j7pd8k6.execute-api.us-west-2.amazonaws.com/production/persistsignalInfo"
let URL_POST_BEACON_REGION_ALERT = "https://boum3gtmxb.execute-api.us-west-2.amazonaws.com/production/persistdevicelog"


//==========================================================================================================
// MARK: - ApiManageDelegate Methods Definition
//==========================================================================================================

@objc protocol ApiManageDelegate: class {

    @objc optional func successGetBeaconsInfo()
    @objc optional func failedGetBeaconsInfo()
    @objc optional func successSendData()
    @objc optional func failedSendData()
    @objc optional func successGetSignalInfo()
    @objc optional func failedGetSignalInfo()

    @objc optional func showMessage(title:String, message:String)
}


class ApiManage: NSObject {
    
    ///  static instance for this class.
    static let sharedApiManage = ApiManage()

    ///  delegat instance.
    var delegate: ApiManageDelegate? = nil

    
    //==========================================================================================================
    // MARK: - Public Methods
    //==========================================================================================================

    ///  get all registered beacons from server.
    func getAllBeaconData () {
        
        QL_LOG_INFO("Getting beacons from server...")
        
        ///  call Alamofire method for getting the data.
        Alamofire.request(URL_GET_BEACONS_DATA, method:.get, encoding:JSONEncoding.default)
            .responseJSON { response in
                
                ///  according to the result.
                switch response.result {
                
                /// success in getting data
                case .success:
                    
                    QL_LOG_INFO("Completed the getting beacons from server successfully")
                    
                    ///  get result value
                    if let result = response.result.value {
                        
                        ///  convert the result to Dictionary object
                        let JSON = result as! NSDictionary
                        
                        ///  get data from "hardwareInfoList" json
                        let arrayHardwareList: NSArray = (JSON["hardwareInfoList"] as? NSArray)!
                        
                        print(arrayHardwareList)
                        
                        /// remove all beacon data in BeaconInfo array.
                        BeaconRegionManager.arrayBeaconList.removeAllObjects()
                        
                        ///  get all beacons from server data.
                        for hardwareInfo in arrayHardwareList {
                            
                            ///  get beacon's UUID
                            let uuid:String = (hardwareInfo as AnyObject).object(forKey: "macId") as! String
                            
                            ///  get beacon's major
                            let major:String = (hardwareInfo as AnyObject).object(forKey: "major") as! String
                            
                            ///  get beacon's minor
                            let minor:String = (hardwareInfo as AnyObject).object(forKey: "minor") as! String
                            
                            ///  get beacon's identifier
                            let identifier:String = (hardwareInfo as AnyObject).object(forKey: "vin") as! String
                            
                            ///  create BeaconInfo object with the beacon info.
                            let beacon = BeaconInfo(uuid:uuid, major:major, minor:minor, identifier:identifier)
                            
                            ///  add the created object into BeaconInfo array
                            BeaconRegionManager.arrayBeaconList.add(beacon)
                        }
                    }
                    
                    ///  if the delegate is set.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - successGetBeaconsInfo")
                        
                        ///  call setter's successGetBeaconsInfo.
                        self.delegate?.successGetBeaconsInfo!()
                    }
                    
                    break
                
                ///  failure in getting data
                case .failure(let error):
                    
                    print(error)
                    
                    QL_LOG_ERROR("Failed the getting beacons from server")
                    
                    ///  if the delegate is set.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - failedGetBeaconsInfo")
                        
                        ///  call setter's failedGetBeaconsInfo.
                        self.delegate?.failedGetBeaconsInfo!()
                    }                    
                }
        }
    }
    
    ///  send the data to server
    func sendDataToServer () {
        
        QL_LOG_INFO("Sending data to server...")

        ///  get current time.
        let currentDateTime = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.dateFormat = "EEE MMM dd hh:mm:ss zzz yyyy"
        let dateString = dateFormatter.string(from: currentDateTime as Date)

        print (dateString)
        
        ///  get app build number.
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        ///  get iOS version.
        let iosVersion = UIDevice.current.systemVersion
        
        ///  get phone uuid
        let phoneId = UIDevice.current.identifierForVendor?.uuidString

        ///  set parameters for sending to server
        var parameters: [String: Any] = [:]
        
        parameters["buildNumber"] = buildNumber
        parameters["groupInfo"] = "MobileSDK"
        parameters["lastUsed"] = dateString
        parameters["macId"] = "UUID"
        parameters["manufacturer"] = "Apple"
        parameters["model"] = "iBeacon"
        parameters["userId"] = phoneId
        parameters["version"] = iosVersion
        
        ///  call Alamofire method for sending the data.
        Alamofire.request(URL_POST_BEACON_DATA, method:.post, parameters: parameters, encoding:JSONEncoding.default)
            .responseJSON { response in
                
                ///  according to the result.
                switch response.result {

                ///  success in sending the data
                case .success:
                    
                    QL_LOG_INFO("Completed the sendign data to server successfully")

                    ///  get result value.
                    if let result = response.result.value {
                        
                        ///  convert result to Dictionary object.
                        let JSON = result as! NSDictionary
                        print(JSON)
                        
                        ///  if getting error message from server.
                        if let errorMessage: String = JSON["errorMessage"] as? String{
                            
                            if self.delegate != nil {
                                
                                QL_LOG_WARNING("Call delegate method - showMessage")
                                
                                ///  show error message.
                                self.delegate?.showMessage!(title: "Error", message: errorMessage)
                            }
                            
                            break
                        }
                    }
                    
                    ///  call successSendData if the data was sent to srver successfully.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - successSendData")
                        
                        self.delegate?.successSendData!()
                    }
                    
                    break
                
                ///  failure in sending the data.
                case .failure(let error):
                    print(error)
                    
                    QL_LOG_ERROR("Failed the sending data to server")

                    ///  call failedSendData if the data wasn't sent to srver.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - failedSendData")

                        self.delegate?.failedSendData!()
                    }
                }
        }
    }
    
    ///  get signal info separately from server.
    func getSignalData () {
        
        QL_LOG_INFO("Getting signal info from server...")
        
        ///  call Alamofire method for getting the data.
        Alamofire.request(URL_GET_SIGNAL_DATA, method:.get, encoding:JSONEncoding.default)
            .responseJSON { response in
                
                ///  according to the result.
                switch response.result {
                    
                /// success in getting data
                case .success:
                    
                    QL_LOG_INFO("Completed the getting signal info from server successfully")
                    
                    ///  get result value
                    if let result = response.result.value {
                        
                        print (result)
                        ///  convert the result to NSArray object
                        BeaconRegionManager.arraySignalList = result as! NSArray
                    }
                    
                    ///  if the delegate is set.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - successGetBeaconsInfo")
                        
                        ///  call setter's successGetBeaconsInfo.
                        self.delegate?.successGetSignalInfo!()
                    }
                    
                    break
                    
                ///  failure in getting data
                case .failure(let error):
                    
                    print(error)
                    
                    QL_LOG_ERROR("Failed the getting beacons from server")
                    
                    ///  if the delegate is set.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - failedGetBeaconsInfo")
                        
                        ///  call setter's failedGetBeaconsInfo.
                        self.delegate?.failedGetSignalInfo!()
                    }
                }
        }
    }
    
    ///  send the data to server
    func sendBeconRegionMessageToServer (beconUDID:String, message:String) {
        
        QL_LOG_INFO("Sending data to server...")
        
        ///  get current time.
        let currentDateTime = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.dateFormat = "EEE MMM dd hh:mm:ss zzz yyyy"
        let dateString = dateFormatter.string(from: currentDateTime as Date)
        
        print (dateString)
        
        ///  get phone uuid
        let phoneId = UIDevice.current.identifierForVendor?.uuidString
        
        ///  set parameters for sending to server
        var parameters: [String: Any] = [:]
        
        parameters["lastUpdateTime"] = dateString
        parameters["macId"] = beconUDID
        parameters["message"] = message
        parameters["severity"] = "low"
        parameters["userId"] = phoneId
        parameters["groupId"] = "MobileSDK"
        parameters["groupInfo"] = "MobileSDK"
        
        ///  call Alamofire method for sending the data.
        Alamofire.request(URL_POST_BEACON_REGION_ALERT, method:.post, parameters: parameters, encoding:JSONEncoding.default)
            .responseJSON { response in
                
                ///  according to the result.
                switch response.result {
                    
                ///  success in sending the data
                case .success:
                    
                    QL_LOG_INFO("Completed the sendign data to server successfully")
                    
                    ///  get result value.
                    if let result = response.result.value {
                        
                        ///  convert result to Dictionary object.
                        let JSON = result as! NSDictionary
                        print(JSON)
                        
                        ///  if getting error message from server.
                        if let errorMessage: String = JSON["errorMessage"] as? String{
                            
                            if self.delegate != nil {
                                
                                QL_LOG_WARNING("Call delegate method - showMessage")
                                
                                ///  show error message.
                                self.delegate?.showMessage!(title: "Error", message: errorMessage)
                            }
                            
                            break
                        }
                    }
                    
                    ///  call successSendData if the data was sent to srver successfully.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - successSendData")
                        
                        self.delegate?.successSendData!()
                    }
                    
                    break
                    
                ///  failure in sending the data.
                case .failure(let error):
                    print(error)
                    
                    QL_LOG_ERROR("Failed the sending data to server")
                    
                    ///  call failedSendData if the data wasn't sent to srver.
                    if self.delegate != nil {
                        
                        QL_LOG_INFO("Call delegate method - failedSendData")
                        
                        self.delegate?.failedSendData!()
                    }
                }
        }
    }
}

///  global instance for this class.
let ApiManager = ApiManage.sharedApiManage
