//
//  main.swift
//  mounty
//
//  Created by Bogdan Ryabyshchuk on 11/27/19.
//  Copyright © 2019 Bogdan Ryabyshchuk. All rights reserved.
//

import Foundation
import NetFS
import CoreWLAN
import Darwin

func printUsage(){
    print("Incorrect arguments.")
    print("Usage: mounty smb://server/share /mount/point [WiFi_SSID]")
}

func exitWithError(_ msg: String){
    print(msg)
    exit(1)
}

let argCount = CommandLine.argc
if(argCount == 3 || argCount == 4){
    // Let's read the arguments
    let argShare = CommandLine.arguments[1]
    let argMountPoint = NSString(string: CommandLine.arguments[2]).expandingTildeInPath
    
    // Check if the arguments make some kind of sense
    if(!argShare.contains("smb://") && !argMountPoint.contains("/")){
        printUsage()
        exitWithError("The share and mount point specified do not make sense.")
    }
    
    if(argCount == 4){
        // Read the SSID cmd argument
        let argWiFiSSID = CommandLine.arguments[3]
        
        // Get current SSID from the system
        let myWiFiSSID = CWWiFiClient.shared().interface()?.ssid() ?? ""
        
        // Check if we are on the right WiFi Network and exit if not
        if(argWiFiSSID != myWiFiSSID){
            exitWithError("ERROR: You are not currently connected to the '\(argWiFiSSID)' WiFi network. Instead you are connected to '\(myWiFiSSID)'. Quitting!")
        }
    }
    
    // Check if the mount point exists
    var isDirectory = ObjCBool(true)
    let exists = FileManager.default.fileExists(atPath: argMountPoint, isDirectory: &isDirectory)
    if(!exists || !isDirectory.boolValue){
        exitWithError("ERROR: The mount point '\(argMountPoint)' either doesn't exist or is not a directory. Quitting!")
    }
    
    // Check if the mount point is already mounted with another volume
    // Let's create a URL from the path
    let mountPoint = URL(fileURLWithPath: argMountPoint)
    
    // Now let's grab all of the mounted volume URLs from the system
    let keys = [URLResourceKey.volumeNameKey, URLResourceKey.volumeIsRemovableKey, URLResourceKey.volumeIsEjectableKey]
    let mounts = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys:keys)
    
    // And let's see if our new mount point is in the list of mounted URLs. Quit if that's the case.
    if let urls = mounts {
        for url in urls {
            if(mountPoint.absoluteString == url.absoluteString){
                exitWithError("ERROR: Looks like '\(mountPoint)' is already mounted. Quitting!")
            }
        }
    }
    
    // Finally, since everything looks OK, let's mount the share
    if let share = URL(string: argShare) {
        // Create Options Dictionary
        let options = NSMutableDictionary()
        options[kNetFSSoftMountKey] = kCFBooleanTrue            // Soft Mount the Share
        options[kNetFSMountAtMountDirKey] = kCFBooleanTrue      // Mount it in the DIR Specified
        
        // Mount the Share
        let mountError = NetFSMountURLSync(share as CFURL, mountPoint as CFURL, nil, nil, nil, options, nil)
        
        if(mountError > 0){
            print("ERROR CODE: \(mountError)")
            exitWithError("ERROR: Could not mount '\(share)'! Quitting!")
        }else{
            print("SUCCESS: '\(share)' is now mounted at '\(mountPoint)'")
            exit(0)
        }
    }
}else{
    printUsage()
    exit(0)
}
