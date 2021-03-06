//
//  ViewController.swift
//  mac-lesson
//
//  Created by Ajay Thakur on 6/21/16.
//  Copyright © 2016 Ajay Thakur. All rights reserved.
//
/// @discussion This is an example using iCloud between two apps Mac and IOS.
/// @discussion This is Mac implementation. The methods in this VC are:
/// @discussion    -- User enters two variables in 'keyNTF: NSTextField' and
/// @discussion    -- 'valueNTF: NSTextField' Then user prsses the button and
/// @discussion    -- '@IBAction func saveIniCloudHandler' gets called
/// @discussion Methods in the class:
/// @discussion    -- 'saveIniCloudHandler': Saves variables in iCloud handlers
/// @discussion    -- 'updateItemsFromiCloud': Handles when notified that the iCloud us changed.
/// @discussion    -- 'initFromiCloudKV': Initializes values from iCloud.
///

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
        initFromiCloudKV()
        initMyPropertyList()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    ///
    /// Comments guidline: http://www.appcoda.com/documenting-source-code-in-xcode/
    /// @brief func saveIniCloudHandler(sender: NSButton)
    ///
    /// @param sender: NSButton
    ///
    /// @discussion THis is invoked when user presses button on Mac Store.
    /// @discussion Saves data in iCloud 'NSUbiquitousKeyValueStore' and
    /// @discussion in local storage -- NSUserDefaults
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
    /// @discussion Handles notifications when the values in iCloud have changed.
    /// 
    /// @param: notification: NSNotification Dictionary containing changes snapshot.
    ///
    /// @discussion If there is notification 'NSUbiquitousKeyValueStoreDidChangeExternallyNotification'
    /// @discussion extract the data and use it.
    /// @discussion
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
    
    ///
    /// @discussion Handles notifications when the values in iCloud have changed.
    ///
    /// @param: None
    ///
    /// @discussion Register for 'NSUbiquitousKeyValueStoreDidChangeExternallyNotification'
    /// @discussion Synchronize the NSUbiquitousKeyValueStore
    /// @discussion Read stored values
    ///
    func initFromiCloudKV() {
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
    
 
    ///
    /// function keyValuesChanged: helper method to extract and save the desired string values.
    ///
    /// @param: key:NSString name of the key that changed
    /// @param: value:NSString the new value that changed
    ///
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
    
    ///
    /// @description Reads the property list file [in XML] and converts to Dictionary
    /// function initMyPropertyList: Read the AppDataStore.plist
    /// @param   None
    ///
    /// @brief here is how the data is stores in XML
    //    <?xml version="1.0" encoding="UTF-8"?>
    //    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    //    <plist version="1.0">
    //      <dict>
    //          <key>Name</key>
    //          <string>Ajay Thakur</string>
    //          <key>Company</key>
    //          <string>Finny Inc</string>
    //          <key>Phone Number</key>
    //          <string>+1 (408) 406-6275</string>
    //          <key>Address</key>
    //          <dict>
    //              <key>Street</key>
    //              <string>Remingtom Drive</string>
    //              <key>Unit Number</key>
    //              <string>910</string>
    //              <key>City</key>
    //              <string>Sunnyvale</string>
    //              <key>State</key>
    //              <string>CA</string>
    //              </dict>
    //          <key>Contributers</key>
    //          <array>
    //              <string>Ajay Thakur</string>
    //              <string>Navneet Bansal</string>
    //              <string>Alex Bush</string>
    //              <string>Chris Gandolfo</string>
    //          </array>
    //      </dict>
    //    </plist>
    //
    // Paths of these files on Mac
    // $HOME/Library/Developer/Xcode/DerivedData/icloudExercise1-aahrjwvwbmzqqsafivskzdvbregg/Build/Products/Debug/mac-lesson.app/Contents/Resources/AppDataStore.plist
    func initMyPropertyList () {
        if let path:String = NSBundle.mainBundle().pathForResource("AppDataStore", ofType: "plist") {
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
