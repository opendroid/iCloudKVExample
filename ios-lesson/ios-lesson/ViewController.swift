//
//  ViewController.swift
//  ios-lesson
//
//  Created by Ajay Thakur on 6/21/16.
//  Copyright © 2016 Ajay Thakur. All rights reserved.
//
/// @discussion This is an example using iCloud between two apps Mac and IOS.
/// @discussion This is IOS implementation. The methods in this VC are:
/// @discussion    -- User enters two variables in 'keyNTF: UITextField' and
/// @discussion    -- 'valueNTF: UITextField' Then user prsses the button and
/// @discussion    -- '@IBAction func saveIniCloudHandler' gets called
/// @discussion Methods in the class:
/// @discussion    -- 'saveIniCloudHandler': Saves variables in iCloud handlers
/// @discussion    -- 'updateItemsFromiCloud': Handles when notified that the iCloud us changed.
/// @discussion    -- 'initFromiCloudKV': Initializes values from iCloud.
///

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var keyUTF: UITextField!
    @IBOutlet weak var valueUTF: UITextField!
    let kKeyFieldKey = "APP_LESSON_KEY"
    let kValueFieldKey = "APP_LESSON_VALUE"
    var keyValueIniCloud: String  = ""// Key value in iCloud
    var keyValueInNSU: String  = "" // Key value in NSU
    var valueValueIniCloud: String  = "" // Value in iCloud
    var valueValueInNSU: String  = ""  // Value in NSU
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        keyUTF.delegate = self;
        valueUTF.delegate = self;
        
        // Setup iCloud values
        setupiCloudKV()
        initMyPropertyList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField.tag {
        case 100:
            NSLog("Key:\(textField.tag): Value:\(textField.text!)")
        default:
            NSLog("Value:\(textField.tag): Value:\(textField.text!)")
        }
    }
    ///
    /// Comments guidline: http://www.appcoda.com/documenting-source-code-in-xcode/
    /// @brief func saveIniCloudHandler(sender: UIButton)
    ///
    /// @param sender: UIButton
    ///
    /// @discussion THis is invoked when user presses button on Mac Store.
    /// @discussion Saves data in iCloud 'NSUbiquitousKeyValueStore' and
    /// @discussion in local storage -- NSUserDefaults
    ///
    @IBAction func saveIniCloudHandler(sender: UIButton) {
        // Save in iCloud
        NSUbiquitousKeyValueStore.defaultStore().setString(keyUTF.text, forKey: kKeyFieldKey)
        NSUbiquitousKeyValueStore.defaultStore().setString(valueUTF.text, forKey: kValueFieldKey)
        
        // Save in NSU
        if let keyValueFromUX = keyUTF.text {
            NSUserDefaults.standardUserDefaults().setObject(keyValueFromUX, forKey: kKeyFieldKey)
            NSLog("Key:\(keyValueFromUX) ... saved in iCloud")
        }
        if let valueValueFromUX = valueUTF.text {
            NSUserDefaults.standardUserDefaults().setObject(valueValueFromUX, forKey: kValueFieldKey)
            NSLog("Value:\(valueValueFromUX) ... saved in iCloud")
        }
    }
    
    ///
    /// function keyValuesChanged: helper method to extract and save the desired string values.
    ///
    /// @param: key:NSString name of the key that changed
    /// @param: value:NSString the new value that changed
    ///
    func keyValuesChanged(key:String, value:String) {
        switch key {
        case kKeyFieldKey:
            keyUTF.text = value as String
            NSUserDefaults.standardUserDefaults().setValue(value, forKey: kKeyFieldKey)
            
        case kValueFieldKey:
            valueUTF.text = value as String
            NSUserDefaults.standardUserDefaults().setValue(value, forKey: kValueFieldKey)
        default: break
            // None
        }
        NSLog("keyValuesChanged: Key:\(key) Value:\(value)")
    }
    
    ///
    /// @discussion Handles notifications when the values in iCloud have changed.
    ///
    /// @param: notification: NSNotification Dictionary containing changes snapshot.
    ///
    /// @discussion If there is notification 'NSUbiquitousKeyValueStoreDidChangeExternallyNotification'
    /// @discussion extract the data and use it.
    /// @discussion
    ///
    func updateItemsFromiCloud(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!;
        
        // Find out what changed
        if let reasonForChange = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangeReasonKey) {
            if let reason = reasonForChange.integerValue {
                if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
                    (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
                    if let changedKeys:NSArray = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangedKeysKey) as? NSArray {
                        for aKey in changedKeys {
                            if ((aKey as! String == kKeyFieldKey) || (aKey as! String == kValueFieldKey) ){
                                let value:NSString = NSUbiquitousKeyValueStore.defaultStore().objectForKey(aKey as! String) as! (String)
                                keyValuesChanged(aKey as! String, value: value as String)
                            } // Only save changes we are interested in
                            NSLog("updateItemsFromiCloud: Key:\(aKey)")
                        } // Iterate through all changes
                    }
                }
            }
        } // Data did change
        NSLog("IOS: updateItemsFromiCloud")
    } // End 'updateItemsFromiCloud'
    
    ///
    /// @discussion Handles notifications when the values in iCloud have changed.
    ///
    /// @param: None
    ///
    /// @discussion Register for 'NSUbiquitousKeyValueStoreDidChangeExternallyNotification'
    /// @discussion Synchronize the NSUbiquitousKeyValueStore
    /// @discussion Read stored values
    ///
    func setupiCloudKV() {
        // Setup the KV iCloud store
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.updateItemsFromiCloud(_:)),
                                                         name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
                                                         object: NSUbiquitousKeyValueStore.defaultStore())
        
        // Set up store
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        
        // Get the values from iCloud -- Use Optional binding to test it
        let iCloudKVStore = NSUbiquitousKeyValueStore.defaultStore()
        if let keyFieldValue = iCloudKVStore.stringForKey(kKeyFieldKey) {
            keyValueIniCloud = keyFieldValue
            keyUTF.text=keyFieldValue
        }
        if let valueFieldValue = iCloudKVStore.stringForKey(kValueFieldKey) {
            valueValueIniCloud = valueFieldValue
            valueUTF.text = valueFieldValue
        }
        
        // Get values from NSU
        let prefs = NSUserDefaults.standardUserDefaults()
        if let keyFieldValue = prefs.stringForKey(kKeyFieldKey) {
            keyValueInNSU = keyFieldValue
        }
        if let valueFieldValue = prefs.stringForKey(kValueFieldKey)  {
            valueValueInNSU = valueFieldValue
        }
        
        NSLog("iCloud: Key:\(keyValueIniCloud) Value:\(valueValueIniCloud)")
        NSLog("NSU: Key:\(keyValueInNSU) Value:\(valueValueInNSU)")
    }
    
    ///
    /// @description Reads the property list file [in XML] and converts to Dictionary
    /// function initMyPropertyList: Read the iosAppData
    /// @param   None
    ///
    // Path of these files in IOS
    // Simulator: $HOME/Library/Developer/CoreSimulator/Devices/48DA72F1-6C86-43D5-952C-1DBF99BA2629/data/Containers/Bundle/Application/
    // iPhone: /var/containers/Bundle/Application/207DCC6E-9192-4C56-AAA8-D6523FC17EA3/ios-lesson.app/iosAppData.plist
    

    func initMyPropertyList () {
        if let path:String = NSBundle.mainBundle().pathForResource("iosAppData", ofType: "plist") {
            NSLog("App property list  \(path)")
            if let xmlData = NSFileManager.defaultManager().contentsAtPath(path) {
                /// @description change XML to Dictionary
                // Note on usage of try! i.e. disables error propogation
                // Because "AppDataStore.plist" is packaged we wont get any error.
                //
                let data = try! NSPropertyListSerialization.propertyListWithData(xmlData, options: NSPropertyListMutabilityOptions.MutableContainersAndLeaves, format: nil)
                NSLog("Dictionary: \(data)!")
            } // End valid xmlData
        } // End valid path
    }
    
}

