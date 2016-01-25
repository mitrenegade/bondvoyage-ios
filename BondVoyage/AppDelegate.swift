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
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure Navigation Bar Appearance
        UINavigationBar.appearance().tintColor = UIColor.BV_defaultBlueColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let img = UIImage()
        UINavigationBar.appearance().shadowImage = img
        UINavigationBar.appearance().setBackgroundImage(img, forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor.BV_navigationBarGrayColor()
        
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
        
        // reenable push. for ios8, isRegisteredForRemoteNotifications doesn't get reset when the app is deleted.
        if PFUser.currentUser() != nil && self.hasPushEnabled() {
            self.initializeNotificationServices()
        }
        
        // Fabric
        Fabric.with([Crashlytics.self])

        if PFUser.currentUser() != nil {
            self.logUser()
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

    // MARK: - Controller stack
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

        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        if PFUser.currentUser() != nil {
            let userId: String = PFUser.currentUser()!.objectId!
            let channel: String = "channel\(userId)"
            installation.addUniqueObject(channel, forKey: "channels") // subscribe to trainers channel
        }
        installation.saveInBackground()

        let channels = installation.objectForKey("channels")
        print("installation registered for remote notifications: token \(deviceToken) channel \(channels)")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("failed: error \(error)")
        NSNotificationCenter.defaultCenter().postNotificationName("push:enable:failed", object: nil)
    }

    // MARK: Push
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
            self.initializeNotificationServices()
        }))
        self.topViewController()!.presentViewController(alert, animated: true, completion: nil)
    }
    
    func initializeNotificationServices() -> Void {
        // http://www.intertech.com/Blog/push-notifications-tutorial-for-ios-9/#ixzz3xXcQVOIC
        let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.sharedApplication().registerForRemoteNotifications()
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

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("notification received: \(userInfo)")
        /* format:
        [aps: {
        alert = "test push 2";
        sound = default;
        }]
        
        // With info:
        [
        [from: {
        objectId = Xpqevj9iZY;
        }, parsePushId: 2LP23eaIpL, fromMatch: {
        categories =     (
        museums
        );
        createdAt = "2016-01-23T22:37:32.208Z";
        inviteTo =     {
        "__type" = Pointer;
        className = Match;
        objectId = dvWIDtvWng;
        };
        objectId = ILtTAMoK6V;
        status = pending;
        updatedAt = "2016-01-23T22:37:41.144Z";
        user =     {
        "__type" = Pointer;
        className = "_User";
        objectId = Xpqevj9iZY;
        };
        }, toMatch: {
        categories =     (
        museums
        );
        createdAt = "2016-01-23T22:37:20.969Z";
        inviteFrom =     {
        "__type" = Pointer;
        className = Match;
        objectId = ILtTAMoK6V;
        };
        objectId = dvWIDtvWng;
        status = pending;
        updatedAt = "2016-01-23T22:37:41.143Z";
        user =     {
        "__type" = Pointer;
        className = "_User";
        objectId = KaxEQenlcS;
        };
        }
        ]
        */
        if let _ = userInfo["from"] as? [NSObject: AnyObject] {
            self.goToInvited(userInfo)
        }
    }
    
    // MARK: - Logging/analytics
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        if PFUser.currentUser() == nil {
            return
        }
        
        let user: PFUser = PFUser.currentUser()!
        if user.email != nil {
            Crashlytics.sharedInstance().setUserEmail(user.email!)
        }
        else if self.isValidEmail(user.username!) {
            Crashlytics.sharedInstance().setUserEmail(user.username!)
        }
        
        if user.objectId != nil {
            Crashlytics.sharedInstance().setUserIdentifier(user.objectId!)
        }
        
        if let name: String = user.valueForKey("firstName") as? String {
            Crashlytics.sharedInstance().setUserName(name)
        }
    }
    
    // MARK: - Invitation notification
    func goToInvited(info: [NSObject: AnyObject]) {
        let userDict: [NSObject: AnyObject] = info["from"] as! [NSObject: AnyObject]
        let userId: String = userDict["objectId"] as! String

        let fromMatch: [NSObject: AnyObject] = info["fromMatch"] as! [NSObject: AnyObject]
        let fromMatchId: String = fromMatch["objectId"] as! String
        
        let query: PFQuery = PFQuery(className: "Match")
        query.whereKey("objectId", equalTo: fromMatchId)
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if results != nil && results!.count > 0 {
                let fromMatch: PFObject = results![0]
                let presenter = self.topViewController()!
                if let nav: UINavigationController = presenter as? UINavigationController {
                    if nav.viewControllers.last!.isKindOfClass(MatchStatusViewController) {
                        let matchController: MatchStatusViewController = nav.viewControllers.last! as! MatchStatusViewController
                        matchController.fromMatch = fromMatch
                        matchController.refresh()
                        return
                    }
                }
                
                let query: PFQuery = PFUser.query()!
                query.whereKey("objectId", equalTo: userId)
                query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                    if results != nil && results!.count > 0 {
                        let user: PFUser = results![0] as! PFUser
                        
                        let controller: UserDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("userDetailsID") as! UserDetailsViewController
                        controller.invitingUser = user
                        controller.invitingMatch = fromMatch
                        
                        let nav = UINavigationController(rootViewController: controller)
                        presenter.presentViewController(nav, animated: true, completion: { () -> Void in
                        })
                    }
                    else {
                        print("Invalid user")
                    }
                }
            }
            else {
            
            }
        })
    }
    
    // MARK: - Utils
    func isValidEmail(testStr:String) -> Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}

