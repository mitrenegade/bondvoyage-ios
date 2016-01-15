//
//  AppDelegate.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/6/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId(PARSE_APP_ID,
            clientKey: PARSE_CLIENT_KEY)
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Test: seed the database with fake users
        UserRequest.seed()
        
        // Test: seed with recommendations. Only do this once
        //RecommendationRequest.seed()
        
        // reregister for push
        if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func topViewController() -> UIViewController? {
        if UIApplication.sharedApplication().keyWindow == nil {
            return nil
        }
        if UIApplication.sharedApplication().keyWindow!.rootViewController == nil {
            return nil
        }
        
        return self.topViewController(UIApplication.sharedApplication().keyWindow!.rootViewController!)
    }
    
    func topViewController(rootViewController: UIViewController) -> UIViewController? {
        if rootViewController.presentedViewController == nil {
            return rootViewController
        }
        
        if rootViewController.presentedViewController!.isKindOfClass(UINavigationController) {
            let nav: UINavigationController = rootViewController.presentedViewController as! UINavigationController
            let lastViewController: UIViewController? = nav.viewControllers.last
            return self.topViewController(lastViewController!)
        }
        
        return self.topViewController(rootViewController.presentedViewController!)
    }
    
    // MARK: - Push
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        NSNotificationCenter.defaultCenter().postNotificationName("push:enabled", object: nil)
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject("bondvoyage", forKey: "channels") // subscribe to trainers channel
        installation.saveInBackground()
        let channels = installation.objectForKey("channels")
        print("installation registered for remote notifications: token \(deviceToken) channel \(channels)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("failed: error \(error)")
        NSNotificationCenter.defaultCenter().postNotificationName("push:enable:failed", object: nil)
    }

    func hasPushEnabled() -> Bool {
        if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
            return false
        }
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if (settings?.types.contains(.Alert) == true){
            return true
        }
        else {
            return false
        }
    }

    func registerForRemoteNotifications() {
        let alert = UIAlertController(title: "Please enable bond invitations", message: "Push notifications are needed in order to bond. To ensure that you can receive these invitations, please click Yes in the next popup.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }))
        self.topViewController()!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func warnForRemoteNotificationRegistrationFailure() {
        let alert = UIAlertController(title: "Change notification settings?", message: "Push notifications are disabled, so you can't receive notifications from trainers. Would you like to go to the Settings to update them?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            print("go to settings")
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.topViewController()!.presentViewController(alert, animated: true, completion: nil)
    }

}

