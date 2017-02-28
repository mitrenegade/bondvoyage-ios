//
//  AppDelegate.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/6/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FBSDKCoreKit
import ParseUI
import ParseFacebookUtilsV4
import Quickblox
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Configure Navigation Bar Appearance
        UINavigationBar.appearance().tintColor = Constants.BV_defaultBlueColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Constants.BV_defaultBlueColor()]
        let img = UIImage()
        UINavigationBar.appearance().shadowImage = img
        UINavigationBar.appearance().setBackgroundImage(img, for: UIBarMetrics.default)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = Constants.BV_navigationBarGrayColor()
        
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        let configuration = ParseClientConfiguration {
            $0.applicationId = PARSE_APP_ID
            $0.clientKey = PARSE_CLIENT_KEY
            $0.server = PARSE_LOCAL ? PARSE_SERVER_URL_LOCAL : PARSE_SERVER_URL
        }
        Parse.initialize(with: configuration)
        
        // register parse subclasses
        Activity.registerSubclass()
        Conversation.registerSubclass()
        User.registerSubclass()

        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)
        
        // Test: seed the database with fake users
        UserRequest.seed()
        
        // Test: seed with recommendations. Only do this once
        //RecommendationRequest.seed()
        
        // Fabric
        Fabric.with([Crashlytics.self])
        
        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions);
        
        if PFUser.current() != nil {
            self.logUser()
        }
        
        // Quickblox
        QBSettings.setApplicationID(QB_APP_ID)
        QBSettings.setAuthKey(QB_AUTH_KEY)
        QBSettings.setAccountKey(QB_ACCOUNT_KEY)
        QBSettings.setAuthSecret(QB_AUTH_SECRET)
        
        
        for family in UIFont.familyNames {
            print(family)
            for name in UIFont.fontNames(forFamilyName: family) {
                print(name)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        // Facebook
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Controller stack
    func topViewController() -> UIViewController? {
        if UIApplication.shared.keyWindow == nil {
            return nil
        }
        if UIApplication.shared.keyWindow!.rootViewController == nil {
            return nil
        }
        
        return self.topViewController(UIApplication.shared.keyWindow!.rootViewController!)
    }
    
    func topViewController(_ rootViewController: UIViewController) -> UIViewController? {
        if rootViewController.presentedViewController == nil {
            return rootViewController
        }
        
        if rootViewController.presentedViewController!.isKind(of: UINavigationController.self) {
            let nav: UINavigationController = rootViewController.presentedViewController as! UINavigationController
            let lastViewController: UIViewController? = nav.viewControllers.last
            return self.topViewController(lastViewController!)
        }
        
        return self.topViewController(rootViewController.presentedViewController!)
    }
    
    // MARK: - Logging/analytics
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        if PFUser.current() == nil {
            return
        }
        
        let user: PFUser = PFUser.current()!
        if user.email != nil {
            Crashlytics.sharedInstance().setUserEmail(user.email!)
        }
        else if self.isValidEmail(user.username!) {
            Crashlytics.sharedInstance().setUserEmail(user.username!)
        }
        
        if user.objectId != nil {
            Crashlytics.sharedInstance().setUserIdentifier(user.objectId!)
        }
        
        if let name: String = user.value(forKey: "firstName") as? String {
            Crashlytics.sharedInstance().setUserName(name)
        }
    }
    
    // MARK: - Utils
    func isValidEmail(_ testStr:String) -> Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // MARK: Redirect
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

// MARK: Push
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushService().registerParsePushSubscription(deviceToken) { (success) in
            print("push subscription success: \(success)")
            //self.notify(NotificationType.Push.Registered.rawValue, object: nil, userInfo: nil)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push failed to register with error \(error)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "push:enable:failed"), object: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("my push is: \(userInfo)")
        UIApplication.shared.applicationIconBadgeNumber = 0
        if application.applicationState == UIApplicationState.inactive {
            print("Inactive")
        }
        
        guard let fromId = userInfo["fromId"], let conversationId = userInfo["conversationId"] else { return }
        
        // handle
        NotificationCenter.default.post(name: Notification.Name(rawValue: "push:received"), object: nil, userInfo: ["fromId": fromId, "conversationId": conversationId])

        // always cause the feed to reload
        NotificationCenter.default.post(name: Notification.Name(rawValue: "activity:updated"), object: nil)
    }
    
    // MARK: Push utils
    func hasPushEnabled() -> Bool {
        if !UIApplication.shared.isRegisteredForRemoteNotifications {
            return false
        }
        let settings = UIApplication.shared.currentUserNotificationSettings
        if (settings?.types.contains(.alert) == true){
            return true
        }
        else {
            return false
        }
    }
    
    func promptForRemoteNotifications() {
        if let timestamp: Date = UserDefaults.standard.object(forKey: "push:request:defer:timestamp") as? Date {
            if Date().timeIntervalSince(timestamp) < 1*24*3600 {
                return
            }
        }
        
        let alert = UIAlertController(title: "Please enable bond invitations", message: "Push notifications are needed in order to bond. To ensure that you can receive these invitations, please click Yes in the next popup.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: { (action) -> Void in
            UserDefaults.standard.set(Date(), forKey: "push:request:defer:timestamp")
            UserDefaults.standard.synchronize()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.initializeNotificationServices()
        }))
        self.topViewController()!.present(alert, animated: true, completion: nil)
    }
    
    func initializeNotificationServices() -> Void {
        /*
        // http://www.intertech.com/Blog/push-notifications-tutorial-for-ios-9/#ixzz3xXcQVOIC
        let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.shared.registerForRemoteNotifications()
        */
        PushService().enablePushNotifications({ (success) in
            if !success {
                //self.simpleAlert("There was an error enabling push", defaultMessage: nil, error: nil, completion: nil)
            }
        })

    }
}
