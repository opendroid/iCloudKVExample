//
//  ViewController.swift
//  ios-lesson
//
//  Created by Ajay Thakur on 6/21/16.
//  Copyright © 2016 Ajay Thakur. All rights reserved.
//

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
    
    // Save the values changed
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
    
    // What happened.
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
}

