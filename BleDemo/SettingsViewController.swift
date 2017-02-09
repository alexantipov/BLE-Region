//
//  SettingsViewController.swift
//  BleDemo
//
//  Created by Alex on 10/20/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import UserNotifications


let TEXTFIELD_BORDER_COLOR = UIColor(red: 172 / 255, green: 217 / 255, blue: 229 / 255, alpha: 1).cgColor
let BUTTON_BORDER_COLOR = UIColor(red: 38 / 255, green: 154 / 255, blue: 186 / 255, alpha: 1).cgColor

/// The main view controller, which basically manages the UI, triggers operations and updates its views.
class SettingsViewController: UIViewController, ApiManageDelegate{

    
    //==========================================================================================================
    // MARK: - UI Controls
    //==========================================================================================================
    
    ///  Dropdown list control
    let dropDownListVehicleType = DropDown ()
    let dropDownListRestrictedAccess = DropDown ()
    
    ///  ActivityIndicator for loading server data control
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    ///  Buttons for Dropdown list
    @IBOutlet weak var buttonVehicleType: UIButton!
    @IBOutlet weak var buttonRestrictedAccess: UIButton!
    @IBOutlet weak var buttonPairYourDevice: UIButton!
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    
    ///  TextFields for phone number
    @IBOutlet weak var textFieldAdminContact: UITextField!
    @IBOutlet weak var textFieldPrimaryContact: UITextField!
    @IBOutlet weak var textFieldSecondaryContact: UITextField!
    
    
    //==========================================================================================================
    // MARK: - Override Methods
    //==========================================================================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        ///  enable log
        QorumLogs.enabled = true

        QLPlusLine()
        QL_LOG_INFO("Starting...")

        ///  set server api delegate
        ApiManager.delegate = self
        
        ///  set current status for viwes
        setInitViewStatus()
        
        ///  init dropdown list
        initDropDwonList ()
        
        ///  set round rect of view and buttons
        setViewsRoundRect()
        
        self.navigationItem.hidesBackButton = true
        
        ///  Looks for single or multiple taps
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //==========================================================================================================
    // MARK: - Keyboard method
    //==========================================================================================================

    ///  Calls this function when the tap is recognized.
    func dismissKeyboard() {
        
        ///  Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        view.endEditing(true)
    }
    

    //==========================================================================================================
    // MARK: - UI Actions
    //==========================================================================================================
   
    ///  show dropdown list
    @IBAction func onDropDownVehicleType(_ sender: AnyObject) {
        
        dropDownListVehicleType.show()
    }
    
    ///  show dropdown list
    @IBAction func onDropDownRestrictedAccess(_ sender: AnyObject) {
        
        dropDownListRestrictedAccess.show()
    }
    
    ///  invoked when user turn on or off the PairedMode.
    @IBAction func onPairYourDevice(_ sender: AnyObject) {
        
        QL_LOG_INFO("PairedMode is turn on")
            
        ///  set pair mode to PAIR_DEVICE.
        BeaconRegionManager.pairedMode = PairedMode.PAIR_DEVICE
        
        ///
        BeaconRegionManager.foundOnlyOneBeacon = false
        
        ///  disable all controls for loading server data
        showControls(bShow: false)
        
        ///  get beacon informations from server
        ApiManager.getAllBeaconData()
        
        if let userDefaults = UserDefaults(suiteName:GROUP_NAME_CURRENT_BEACON) {
            userDefaults.setValue(true, forKey: GROUP_CURRENT_BEACON_PAIR)
        }

        QL_LOG_INFO("The beacon pair mode is saved into local storage")
        
        ///  store current pair mode into local storage with BEACON_PAIRED_MODE
        UserDefaults.standard.setValue(BeaconRegionManager.pairedMode.rawValue, forKey: BEACON_PAIRED_MODE)//for background mode
    }
    
    ///  sends the data to server
    @IBAction func onSubmit(_ sender: AnyObject) {
        
        ///  store the phone numbers and dropdown into local storage

        UserDefaults.standard.setValue(textFieldAdminContact.text, forKey: ADMIN_CONTACT_NUMBER)
        UserDefaults.standard.setValue(textFieldPrimaryContact.text, forKey: PRIMARY_CONTACT_NUMBER)
        UserDefaults.standard.setValue(textFieldSecondaryContact.text, forKey: SECONDARY_CONTACT_NUMBER)

        UserDefaults.standard.setValue(self.buttonVehicleType.currentTitle, forKey: DROPDOWN_VEHICLE_TYPE)
        UserDefaults.standard.setValue(self.buttonRestrictedAccess.currentTitle, forKey: DROPDOWN_RESTRICTED_ACCESS)

        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    ///  save the changed phone number into local storage
    @IBAction func onChangeAdminContact(_ sender: AnyObject) {

        QL_LOG_INFO("Admin Number was changed")
    }
    
    ///  save the changed phone number into local storage
    @IBAction func onChangePrimaryContact(_ sender: AnyObject) {
        
        QL_LOG_INFO("Primary Number was changed")
    }
    
    ///  save the changed phone number into local storage
    @IBAction func onChangeSecondary(_ sender: AnyObject) {
        
        QL_LOG_INFO("Secondary Number was changed")
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
        self.buttonVehicleType.isEnabled = bShow
        self.buttonRestrictedAccess.isEnabled = bShow
        self.buttonPairYourDevice.isEnabled = bShow
        self.buttonSubmit.isEnabled = bShow
        self.buttonCancel.isEnabled = bShow
        self.textFieldAdminContact.isEnabled = bShow
        self.textFieldPrimaryContact.isEnabled = bShow
        self.textFieldSecondaryContact.isEnabled = bShow
        
        ///  show or hide the activityindicator
        if bShow == false {
            
            self.activityIndicator.startAnimating()
        } else {
            
            self.activityIndicator.stopAnimating()
        }
    }
    
    ///  set all view's values
    func setInitViewStatus () {
        
        QL_LOG_INFO("Init switchs for PairedMode")

        ///  get pair mode from local storage with BEACON_PAIRED_MODE
        if let pair = UserDefaults.standard.value(forKey: BEACON_PAIRED_MODE) {
            
            ///  set pair mode
            BeaconRegionManager.pairedMode = PairedMode(rawValue: pair as! Int)!
            
            ///  set foundOnlyOneBeacon for the PairedMode
            if BeaconRegionManager.pairedMode == PairedMode.PAIR_DEVICE {
                
                BeaconRegionManager.pairedMode = PairedMode.NONE
                onPairYourDevice(buttonPairYourDevice)
            } 
        }
        
        ///  get and set the phone numbers and dropdown from local storage
        if let adminNumber = UserDefaults.standard.value(forKey: ADMIN_CONTACT_NUMBER) as! String? {
            textFieldAdminContact.text = adminNumber
        }
        if let primaryNumber = UserDefaults.standard.value(forKey: PRIMARY_CONTACT_NUMBER) as! String? {
            textFieldPrimaryContact.text = primaryNumber
        }
        
        if let secondaryNumber = UserDefaults.standard.value(forKey: SECONDARY_CONTACT_NUMBER) as! String? {
            textFieldSecondaryContact.text = secondaryNumber
        }
        
        if let vehicleType = UserDefaults.standard.value(forKey: DROPDOWN_VEHICLE_TYPE) as! String? {
            self.buttonVehicleType.setTitle(vehicleType, for: .normal)
        }
        
        if  let restrictedAccess = UserDefaults.standard.value(forKey: DROPDOWN_RESTRICTED_ACCESS) as! String? {
            self.buttonRestrictedAccess.setTitle(restrictedAccess, for: .normal)
        }

    }
    
    func initDropDwonList () {
        
        QL_LOG_INFO("Init  Dropdown List")

        // The view to which the drop down will appear on
        dropDownListVehicleType.anchorView = buttonVehicleType // UIView or UIBarButtonItem
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        dropDownListVehicleType.bottomOffset = CGPoint(x: 0, y: buttonVehicleType.bounds.height)
        // The list of items to display. Can be changed dynamically
        dropDownListVehicleType.dataSource = ["Small Car", "Full Size Car", "Van"]
        
        DropDown.appearance().selectionBackgroundColor = UIColor(red: 38 / 255, green: 154 / 255, blue: 186 / 255, alpha: 1)

        // Action triggered on selection
        dropDownListVehicleType.selectionAction = { [unowned self] (index: Int, item: String) in
            
            QL_LOG_INFO("dropDownListVehicleType's value was changed")

            print("Selected item: \(item) at index: \(index)")
            
            self.buttonVehicleType.setTitle(item, for: .normal)
            
            ///  disable all controls for loading server data
            self.showControls(bShow: false)
            
            ///  get signal informations from server
            ApiManager.getSignalData()
        }
        
        // The view to which the drop down will appear on
        dropDownListRestrictedAccess.anchorView = buttonRestrictedAccess // UIView or UIBarButtonItem
        
        dropDownListRestrictedAccess.bottomOffset = CGPoint(x: 0, y: buttonRestrictedAccess.bounds.height)
        // The list of items to display. Can be changed dynamically
        dropDownListRestrictedAccess.dataSource = ["Continuous", "Manual"]
        
        // Action triggered on selection
        dropDownListRestrictedAccess.selectionAction = { [unowned self] (index: Int, item: String) in
            
            QL_LOG_INFO("dropDownListRestrictedAccess's value was changed")
            
            print("Selected item: \(item) at index: \(index)")
            
            self.buttonRestrictedAccess.setTitle(item, for: .normal)
        }
        
        if let userDefaults = UserDefaults(suiteName:GROUP_NAME_CURRENT_BEACON) {
            
            if (userDefaults.value(forKey: GROUP_SIGNAL_IB) != nil) {
                
                return;
            }
            
        }
        
        ///  disable all controls for loading server data
        showControls(bShow: false)
        
        ///  get signal informations from server
        ApiManager.getSignalData()

    }
    
    ///  set round rect of views and buttons
    func setViewsRoundRect () {
        
        QL_LOG_INFO("Set RoundRect of Views")

        ///  set textfields border and color
        textFieldAdminContact.layer.cornerRadius = BUTTON_CORNER_RADIUS
        textFieldAdminContact.clipsToBounds = true
        textFieldAdminContact.layer.borderWidth = 1.0
        textFieldAdminContact.layer.borderColor = TEXTFIELD_BORDER_COLOR
        
        textFieldPrimaryContact.layer.cornerRadius = BUTTON_CORNER_RADIUS
        textFieldPrimaryContact.clipsToBounds = true
        textFieldPrimaryContact.layer.borderWidth = 1.0
        textFieldPrimaryContact.layer.borderColor = TEXTFIELD_BORDER_COLOR

        textFieldSecondaryContact.layer.cornerRadius = BUTTON_CORNER_RADIUS
        textFieldSecondaryContact.clipsToBounds = true
        textFieldSecondaryContact.layer.borderWidth = 1.0
        textFieldSecondaryContact.layer.borderColor = TEXTFIELD_BORDER_COLOR

        ///  set buttons border and color
        buttonVehicleType.layer.cornerRadius = BUTTON_CORNER_RADIUS
        buttonVehicleType.clipsToBounds = true
        buttonVehicleType.layer.borderWidth = 2.0
        buttonVehicleType.layer.borderColor = BUTTON_BORDER_COLOR
        
        buttonRestrictedAccess.layer.cornerRadius = BUTTON_CORNER_RADIUS
        buttonRestrictedAccess.clipsToBounds = true
        buttonRestrictedAccess.layer.borderWidth = 2.0
        buttonRestrictedAccess.layer.borderColor = BUTTON_BORDER_COLOR
        
        buttonSubmit.layer.cornerRadius = BUTTON_CORNER_RADIUS
        buttonSubmit.clipsToBounds = true
        buttonSubmit.layer.borderWidth = 2.0
        buttonSubmit.layer.borderColor = BUTTON_BORDER_COLOR
        
        buttonCancel.layer.cornerRadius = BUTTON_CORNER_RADIUS
        buttonCancel.clipsToBounds = true
        buttonCancel.layer.borderWidth = 2.0
        buttonCancel.layer.borderColor = BUTTON_BORDER_COLOR
        
        buttonPairYourDevice.layer.cornerRadius = BUTTON_CORNER_RADIUS
        buttonPairYourDevice.clipsToBounds = true
    }
    

    //==========================================================================================================
    // MARK: - ApiManageDelegate Mthods
    //==========================================================================================================
    
    ///  invoked when the beacons info are got from server successfully.
    func successGetBeaconsInfo() {
        
        QL_LOG_INFO("Successfully got the beacons' info from server")
        
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in}

        ///  enable all controls and hide IndicatorActivity control.
        showControls(bShow: true)
        
        ///  stop all beacons region.
        BeaconRegionManager.stopAllBeacons()

        ///  if the getting data is empty...
        if BeaconRegionManager.arrayBeaconList.count == 0 {
            
            QL_LOG_WARNING("The server has no the registered beacons")
            
            ///  clear local storage with LOCAL_STORAGE_BEACON_LIST.
            if UserDefaults.standard.value(forKey: LOCAL_STORAGE_BEACON_LIST) != nil {
                
                UserDefaults.standard.removeObject(forKey: LOCAL_STORAGE_BEACON_LIST)
            }
            
            ///  show alert
            let alert = UIAlertController(title: "Alert", message: "There are no data.", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        } else {
        
            ///  if the data of local storage with LOCAL_STORAGE_BEACON_LIST exists...
            if let placeData = UserDefaults.standard.value(forKey: LOCAL_STORAGE_BEACON_LIST) {
                
                QL_LOG_INFO("Got the beacons' info from local storage")
                
                ///  get the data of local storage.
                let arrayLocalStorageBeaconList:NSMutableArray = (NSKeyedUnarchiver.unarchiveObject(with: placeData as! Data) as? NSMutableArray)!
                
                /// if the data of local storage exists...
                if arrayLocalStorageBeaconList.count > 0 {
                    
                    QL_LOG_INFO("Compare beacons of server and local storage")
                    
                    for i in 0  ..< BeaconRegionManager.arrayBeaconList.count {
                        
                        for j in 0  ..< arrayLocalStorageBeaconList.count {
                            
                            ///  beacon's info from server.
                            let newBeacon:BeaconInfo = BeaconRegionManager.arrayBeaconList.object(at: i) as! BeaconInfo
                            
                            ///  beacon info from local storage.
                            let oldBeacon:BeaconInfo = arrayLocalStorageBeaconList.object(at: j) as! BeaconInfo
                            
                            ///  search same beacon...
                            if newBeacon.uuid.uppercased() == oldBeacon.uuid.uppercased() || newBeacon.identifier == oldBeacon.identifier {
                                
                                ///  set old number of signals to new one.
                                newBeacon.numberofsignals = oldBeacon.numberofsignals
                            }
                        }
                    }
                }
            }
            
            QL_LOG_INFO("Store server's beacons into local storage")

            ///  store beacon array from server into local storage with LOCAL_STORAGE_BEACON_LIST
            let encodedData = NSKeyedArchiver.archivedData( withRootObject: BeaconRegionManager.arrayBeaconList)
            UserDefaults.standard.set(encodedData, forKey: LOCAL_STORAGE_BEACON_LIST)
            
            ///  start all beacons' region.
            BeaconRegionManager.startAllBeacons()
        }
    }
    
    ///  invoked when the beacons' info from server didn't be got.
    func failedGetBeaconsInfo() {
        
        QL_LOG_ERROR("Failed the getting beacons from server")

        showMessage(title: "Alert", message: "You network has error.")
    }
    
    ///  invoked when the signal info are got from server successfully.
    func successGetSignalInfo() {
        
        QL_LOG_INFO("Successfully got the signal's info from server")
        
        ///  enable all controls and hide IndicatorActivity control.
        showControls(bShow: true)
        
        for signalInfo in BeaconRegionManager.arraySignalList {
            
            ///  get type
            let type:String = (signalInfo as AnyObject).object(forKey: "userid") as! String
            
            ///  get beacon's major
            let ib:String = (signalInfo as AnyObject).object(forKey: "ib") as! String
            let ub:String = (signalInfo as AnyObject).object(forKey: "ub") as! String
            
            var selectedType:String = (self.buttonVehicleType.titleLabel?.text)!
            selectedType = selectedType.replacingOccurrences(of: " ", with: "")

            if selectedType.uppercased() == type.uppercased() {
                
                QL_LOG_INFO("Store signal info into local storage")

                if let userDefaults = UserDefaults(suiteName:GROUP_NAME_CURRENT_BEACON) {
                    userDefaults.setValue(ib, forKey: GROUP_SIGNAL_IB)
                    userDefaults.setValue(ub, forKey: GROUP_SIGNAL_UB)
                }
            }
        }
    }

    ///  invoked when the signal's info from server didn't be got.
    func failedGetSignalInfo() {
        
        QL_LOG_ERROR("Failed the getting beacons from server")
        
        showMessage(title: "Alert", message: "You network has error.")
    }
    
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
