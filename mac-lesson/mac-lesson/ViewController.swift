//
//  ViewController.swift
//  mac-lesson
//
//  Created by Ajay Thakur on 6/21/16.
//  Copyright © 2016 Ajay Thakur. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var keyNTF: NSTextField!
    @IBOutlet weak var valueNTF: NSTextField!
    let kKeyFieldKey = "APP_LESSON_KEY"
    let kValueFieldKey = "APP_LESSON_VALUE"
    var keyValueIniCloud: String = ""  // Key value in iCloud
    var keyValueInNSU: String = "" // Key value in NSU
    var valueValueIniCloud: String = "" // Value in iCloud
    var valueValueInNSU: String = ""  // Value in NSU
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupiCloudKV()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    /// Comments guidline: http://www.appcoda.com/documenting-source-code-in-xcode/
    /// @brief func saveIniCloudHandler(sender: NSButton)
    /// @param sender: NSButton
    /// @discussion THis is invoked when user presses button on Mac Store.
    /// @discussion Saves data in iCloud 'NSUbiquitousKeyValueStore' and
    /// @discussion Local storage -- NSUserDefaults
    ///
    @IBAction func saveIniCloudHandler(sender: NSButton) {
        let keyValueFromUX = keyNTF.stringValue
        let valueValueFromUX = valueNTF.stringValue
        
        NSLog("Mac: Key:\(keyValueFromUX) Value:\(valueValueFromUX)")
        NSUbiquitousKeyValueStore.defaultStore().setString(keyValueFromUX, forKey: kKeyFieldKey)
        NSUbiquitousKeyValueStore.defaultStore().setString(valueValueFromUX, forKey: kValueFieldKey)
        
        // Save in NSU
        NSUserDefaults.standardUserDefaults().setObject(keyValueFromUX, forKey: kKeyFieldKey)
        NSUserDefaults.standardUserDefaults().setObject(valueValueFromUX, forKey: kValueFieldKey)
        NSLog("Key:\(keyValueFromUX): Value:\(valueValueFromUX) ... save in iCloud")
    }
    
    ///
    /// @discussion Notification
    ///
    func updateItemsFromiCloud(notification: NSNotification) {
        // What changed.
        let userInfo:NSDictionary = notification.userInfo!;
        
        /// @brief
        /// @brief Find out what changed
        if let reasonForChange = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangeReasonKey) {
            if let reason = reasonForChange.integerValue {
                if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
                    (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
                    if let changedKeys:NSArray = userInfo.objectForKey(NSUbiquitousKeyValueStoreChangedKeysKey) as? NSArray {
                        for aKey in changedKeys {
                            if ((aKey as! String == kKeyFieldKey) || (aKey as! String == kValueFieldKey) ){
                                let value:NSString = NSUbiquitousKeyValueStore.defaultStore().objectForKey(aKey as! String) as! (String)
                                keyValuesChanged(aKey as! NSString, value: value)
                            } // Only save changes we are interested in
                            NSLog("updateItemsFromiCloud: Key:\(aKey)")
                        } // Iterate through all changes
                    } // If any keys are changed
                } // Is there a reason for change
            }
        } // end if /// Data did change
        NSLog("MAC: updateItemsFromiCloud")
        
    }
    
    func setupiCloudKV() {
        // Setup the KV iCloud store
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.updateItemsFromiCloud(_:)),
                                                         name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
                                                         object: NSUbiquitousKeyValueStore.defaultStore())
        
        // Set up store
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
        
        // Get the values from iCloud
        let store:NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.defaultStore();
        if let keyFieldValue = store.stringForKey(kKeyFieldKey) {
            keyValueIniCloud = keyFieldValue
            keyNTF.stringValue = keyFieldValue
        }
        if let valueFieldValue = store.stringForKey(kValueFieldKey) {
            valueValueIniCloud = valueFieldValue
            valueNTF.stringValue = valueFieldValue
        }
        
        // Get values from NSU
        let prefs = NSUserDefaults.standardUserDefaults()
        if let keyFieldValue = prefs.stringForKey(kKeyFieldKey) {
            keyValueInNSU = keyFieldValue
        }
        if let valueFieldValue = prefs.stringForKey(kValueFieldKey) {
            valueValueInNSU = valueFieldValue
        }
        
        NSLog("iCLoud: Key:\(keyValueIniCloud) Value:\(valueValueIniCloud)")
        NSLog("NSU: Key:\(keyValueInNSU) Value:\(valueValueInNSU)")
    }
    
    // Save the values changed
    func keyValuesChanged(key:NSString, value:NSString) {
        let prefs = NSUserDefaults.standardUserDefaults()
        switch key {
        case kKeyFieldKey:
            keyNTF.stringValue = value as String
            prefs.setValue(value, forKey: kKeyFieldKey)
        case kValueFieldKey:
            valueNTF.stringValue = value as String
            prefs.setValue(value, forKey: kValueFieldKey)
        default: break
            // None
        }
        NSLog("keyValuesChanged: Key:\(key) Value:\(value)")
    }
    
}
