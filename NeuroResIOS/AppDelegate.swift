//
//  AppDelegate.swift
//  NeuroResIOS
//
//  Created by Charles McKay on 2/23/17.
//  Copyright © 2017 Charles McKay. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate{

    static let BASE_URL = "https://neurores.ucsd.edu/"
    static let SOCKET_URL = "wss://neurores.ucsd.edu:3001"
    static let NONE = 0
    static let NO_INTERNET = 1
    static let AUTHENTICATION = 2
    
    static let CACHE_USERS_LIST     = "USERS_LIST"
    static let CACHE_CONV           = "CONV"
    static let CACHE_CONV_PHONEBOOK = "PHONEBOOK"
    
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = uicolorFromHex(rgbValue: 0xffffff)
        navigationBarAppearace.barTintColor = uicolorFromHex(rgbValue: 0x182b49)
        
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        UIApplication.shared.registerForRemoteNotifications()
        
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        
        return true
    }
    
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name("MY_NAME_NOTIFICATION"), object: nil, userInfo: nil)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Handle remote notification registration.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        // Forward the token to your provider, using a custom method.
        //self.enableRemoteNotificationFeatures()
        
        //throw MyError.RuntimeError("hi")
        //self.forwardTokenToServer(token: deviceToken)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
        //self.disableRemoteNotificationFeatures()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
        //    print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        let c_str = userInfo["conv_memb"]!
        let conv_mems_j = JSON.init(parseJSON: c_str as! String)
        
        var conv_mems = [Int]()
        
        for x in conv_mems_j.array! {
            conv_mems.append(x.int!)
        }
        
        
        /*if(application.applicationState == UIApplicationState.active){
            print("was active")
        }else{
            SlideMenuController.setConversationMembersGroup(id: conv_mems)
        }*/
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

