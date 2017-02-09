//
//  MainViewController.swift
//  BleDemo
//
//  Created by Alex on 11/9/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit


let ADMIN_CONTACT_NUMBER = "AdminContactNumber"
let PRIMARY_CONTACT_NUMBER = "PrimaryContactNumber"
let SECONDARY_CONTACT_NUMBER = "SecondaryContactNumber"

let DROPDOWN_VEHICLE_TYPE = "DropdownVehicleType"
let DROPDOWN_RESTRICTED_ACCESS = "DropdownRestrictedAccess"

let SENT_DEVICE_INFO_TO_SERVER = "SentDeviceInfoToServer"

let CHECK_STARTUP_PASSWORD = "CheckStartupPassword"

let VIEW_CORNER_RADIUS = CGFloat(10.0)
let BUTTON_CORNER_RADIUS = CGFloat(5.0)


/// The main view controller, which basically manages the UI, triggers operations and updates its views.
class MainViewController: UIViewController, ApiManageDelegate {

    //==========================================================================================================
    // MARK: - UI Controls
    //==========================================================================================================

    @IBOutlet weak var viewContainerContacts: UIView!
    @IBOutlet weak var viewContainerApps: UIView!
    @IBOutlet weak var viewContainerEmergency: UIView!

    ///  ActivityIndicator for sending the iOS device info to server
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// controls
    @IBOutlet weak var switchPrimaryContact: UISwitch!
    @IBOutlet weak var switchSecondaryContact: UISwitch!
    @IBOutlet weak var switchEmergencyContact: UISwitch!
    @IBOutlet weak var buttonMap: UIButton!
    @IBOutlet weak var buttonMusic: UIButton!
    
    //==========================================================================================================
    // MARK: - Override Methods
    //==========================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///  set raius corner
        viewContainerContacts.layer.cornerRadius = VIEW_CORNER_RADIUS
        viewContainerContacts.clipsToBounds = true
        
        viewContainerApps.layer.cornerRadius = VIEW_CORNER_RADIUS
        viewContainerApps.clipsToBounds = true
        
        viewContainerEmergency.layer.cornerRadius = VIEW_CORNER_RADIUS
        viewContainerEmergency.clipsToBounds = true
        
        ///  set title image
        let logo = UIImage(named: "title.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

        ///  navigation bar's right button
        let passwordImage   = UIImage(named: "settings")
        let passwordButton   = UIBarButtonItem(image: passwordImage,  style:UIBarButtonItemStyle.plain, target: self, action: #selector(MainViewController.onTapPassword(_:)))
        self.navigationItem.rightBarButtonItem = passwordButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
//        checkStartupPassword ()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //==========================================================================================================
    // MARK: - UI Mthods
    //==========================================================================================================
    
    ///  enbale or disable all controls, also show or hide the activityindicator.
    func showControls(bShow:Bool) {
        
        if bShow == true {
            QL_LOG_INFO("Enable controls and Hide ActivityIndicator")
        } else {
            QL_LOG_INFO("Disable controls and Show ActivityIndicator")
        }
        
        ///  enable or disable all controls.
        self.switchPrimaryContact.isEnabled = bShow
        self.switchSecondaryContact.isEnabled = bShow
        self.switchEmergencyContact.isEnabled = bShow
        self.buttonMap.isEnabled = bShow
        self.buttonMusic.isEnabled = bShow
        self.navigationItem.rightBarButtonItem?.isEnabled = bShow
        
        ///  show or hide the activityindicator
        if bShow == false {
            
            self.activityIndicator.startAnimating()
        } else {
            
            self.activityIndicator.stopAnimating()
        }
    }

    ///  show alert action to enter password
    func checkStartupPassword() {
        
        if let _:Bool = UserDefaults.standard.value(forKey: CHECK_STARTUP_PASSWORD) as? Bool {
            
            self.sendToServer ()
            return
        }
        
        QL_LOG_INFO("Checking startup password")
        
        //  Create the alert controller.
        let alert = UIAlertController(title: "Enter Password", message: "", preferredStyle: .alert)
        
        //  Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your password"
            textField.isSecureTextEntry = true
        }
        
        //  Grab the value from the text field, and print it when the user clicks Submit.
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            
            if textField.text == "1" {
                UserDefaults.standard.set(true, forKey: CHECK_STARTUP_PASSWORD)
                self.sendToServer ()
                
                return
            }
            
            self.checkStartupPassword ()
        }))
        
        //  Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    ///  show alert action to enter password
    func onTapPassword(_ sender: AnyObject) {
        
        QL_LOG_INFO("Tap onTapPassword method")

        //  Create the alert controller.
        let alert = UIAlertController(title: "Enter Password", message: "", preferredStyle: .alert)
        
        //  Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your password"
            textField.isSecureTextEntry = true
        }
        
        //  Grab the value from the text field, and print it when the user clicks Submit.
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            
            if textField.text == "password" {
                let settingsViewController =  self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                self.navigationController?.pushViewController(settingsViewController, animated: true)
            }

        }))
        
        //  Cancel the value from the text field, and print it when the user clicks Cancel.
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
        }))
        
        //  Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func turnOffSwitch(timer:Timer) {
        // Something cool
        
        let switchButton = timer.userInfo as! UISwitch
        switchButton.setOn(false, animated: true)

        timer.invalidate()
    }


    ///  call for first phone number
    @IBAction func onCallPrimaryContact(_ sender: AnyObject) {
        
        QL_LOG_INFO("Call Primary Contact")

        let switchCall = sender as! UISwitch
        
        if (switchCall.isOn) {
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.turnOffSwitch), userInfo: switchCall, repeats: false)

            if let number:String  = UserDefaults.standard.value(forKey: PRIMARY_CONTACT_NUMBER) as? String {
                let telNumber = "tel:" + number
                if let url = NSURL(string: telNumber) , UIApplication.shared.canOpenURL(url as URL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url as URL, options: [:],
                                                  completionHandler: {
                                                    (success) in
                                                    print("call successful")
                        })
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(url as URL)
                    }
                }
            }
        }
    }
    
    ///  call for second phone number
    @IBAction func onCallSecondaryContact(_ sender: AnyObject) {
        
        QL_LOG_INFO("Call Secondary Contact")

        let switchCall = sender as! UISwitch
        
        if (switchCall.isOn) {
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.turnOffSwitch), userInfo: switchCall, repeats: false)

            if let number:String = UserDefaults.standard.value(forKey: SECONDARY_CONTACT_NUMBER) as? String {
                let telNumber = "tel:" + number
                if let url = NSURL(string: telNumber) , UIApplication.shared.canOpenURL(url as URL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url as URL, options: [:],
                                                  completionHandler: {
                                                    (success) in
                                                    print("call successful")
                        })
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(url as URL)
                    }
                }
            }
        }
    }
    
    ///  call for emergecy 911
    @IBAction func onCallEmergency(_ sender: AnyObject) {
        
        QL_LOG_INFO("Call Emergency 911")

        let switchCall = sender as! UISwitch
        
        if (switchCall.isOn) {
            
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.turnOffSwitch), userInfo: switchCall, repeats: false)

            if let url = NSURL(string: "tel:911") , UIApplication.shared.canOpenURL(url as URL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL, options: [:],
                                              completionHandler: {
                                                (success) in
                                                print("call successful")
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
    }
    
    
    ///  open map app
    @IBAction func onOpenMapApp(_ sender: AnyObject) {

        QL_LOG_INFO("Open map app")

        if let url = NSURL(string: "http://maps.apple.com/?q=") , UIApplication.shared.canOpenURL(url as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("call successful")
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    ///  open music app
    @IBAction func onOpenMusicApp(_ sender: AnyObject) {
        
        QL_LOG_INFO("Open music app")

        if let url = NSURL(string: "music://") , UIApplication.shared.canOpenURL(url as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("call successful")
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    //==========================================================================================================
    // MARK: - API Call method
    //==========================================================================================================

    func sendToServer () {
        
        if let sentData:Bool = UserDefaults.standard.value(forKey: SENT_DEVICE_INFO_TO_SERVER) as? Bool {
            
            if sentData == true {
                return
            }
        }

        ///  set server api delegate
        ApiManager.delegate = self

        showControls (bShow: false)

        QL_LOG_INFO("Call onSendDataToServer method")

        ///  call for sending data to server.
        ApiManager.sendDataToServer()

    }
    
    //==========================================================================================================
    // MARK: - ApiManageDelegate Mthods
    //==========================================================================================================

    ///  invoked when the sending data to server was completed successfully.
    func successSendData() {
        
        QL_LOG_INFO("Sent the data to server successfully")
        
        UserDefaults.standard.setValue(true, forKey: SENT_DEVICE_INFO_TO_SERVER)

        showMessage(title: "Alert", message: "The data was sent to server successfully.")
    }
    
    ///  invoked when the sending data to server was failed.
    func failedSendData() {
        
        QL_LOG_ERROR("Failed the data to server")
        
        UserDefaults.standard.setValue(false, forKey: SENT_DEVICE_INFO_TO_SERVER)

        showMessage(title: "Alert", message: "You network has error.")
    }
    
    ///  show message
    func showMessage(title:String, message:String) {
        
        ///  enable all controls and hide IndicatorActivity control.
        showControls(bShow: true)
        
        ///  show alert
        let alert = UIAlertController(title: title, message: message, preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
