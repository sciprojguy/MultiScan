//
//  AppDelegate.swift
//  MultiScan
//
//  Created by Chris Woodard on 6/19/18.
//  Copyright © 2018 Chris Woodard. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func getDevice(token:String) -> Device {
    
        let dev = UIDevice.current
        let deviceName = dev.name
        let osVersion = dev.systemVersion
        let deviceModel = dev.localizedModel
        let deviceModelName = mapToDevice(identifier: deviceModel)
        let device = Device(deviceName: deviceName, deviceType: deviceModelName, deviceOS: osVersion, deviceToken: token, appId: "com.Simple.MultiScan")
        return device
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
        let deviceTokenString = deviceToken.hexString
        let devInfo = getDevice(token: deviceTokenString)
    
        //okey dokey, we've got the device token and shit is happening
        //now call the API.
        let apns = APNS.shared
        apns.register(device: devInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("ARGH")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        Fabric.with([Crashlytics.self])

#if DEBUG
#else
    UNUserNotificationCenter.current().requestAuthorization(options: [UNAuthorizationOptions.alert,
            UNAuthorizationOptions.badge]) { didIt, err in
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
#endif

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
    #if os(iOS)
    switch identifier {
    case "iPod5,1":                                 return "iPod Touch 5"
    case "iPod7,1":                                 return "iPod Touch 6"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
    case "iPhone4,1":                               return "iPhone 4s"
    case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
    case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
    case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
    case "iPhone7,2":                               return "iPhone 6"
    case "iPhone7,1":                               return "iPhone 6 Plus"
    case "iPhone8,1":                               return "iPhone 6s"
    case "iPhone8,2":                               return "iPhone 6s Plus"
    case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
    case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
    case "iPhone8,4":                               return "iPhone SE"
    case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
    case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
    case "iPhone10,3", "iPhone10,6":                return "iPhone X"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
    case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
    case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
    case "iPad6,11", "iPad6,12":                    return "iPad 5"
    case "iPad7,5", "iPad7,6":                      return "iPad 6"
    case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
    case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
    case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
    case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
    case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
    case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
    case "AppleTV5,3":                              return "Apple TV"
    case "AppleTV6,2":                              return "Apple TV 4K"
    case "AudioAccessory1,1":                       return "HomePod"
    case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
    default:                                        return identifier
    }
    #elseif os(tvOS)
    switch identifier {
    case "AppleTV5,3": return "Apple TV 4"
    case "AppleTV6,2": return "Apple TV 4K"
    case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
    default: return identifier
    }
    #endif
}
