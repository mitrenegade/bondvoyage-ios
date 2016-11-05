//
//  WelcomeViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import ParseUI
import FBSDKCoreKit


class WelcomeViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var inTransitionToLogin: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLogout", name: "logout", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (PFUser.currentUser() == nil) {
            self.goToLogin()
        }
        else {
            if !inTransitionToLogin {
                self.didLogin()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToLogin() {
        let loginViewController = LoginViewController()
        loginViewController.fields = [.UsernameAndPassword, .LogInButton, .PasswordForgotten, .SignUpButton, .Facebook]
        loginViewController.emailAsUsername = true
        loginViewController.delegate = self
        loginViewController.signUpController?.delegate = self
        self.presentViewController(loginViewController, animated: false, completion: nil)
    }

    // MARK: ParseUI
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.didLogin()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.didLogin()
    }
    
    func didLogin() {
        inTransitionToLogin = true
        
        // Facebook info
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            print("\(result) \nerror: \(error)")
            if result != nil {
                if let dict = result as? [String: String] {
                    if let name = dict["name"] {
                        print("name: \(name)")
                        if PFUser.currentUser()?.objectForKey("firstName") == nil {
                            PFUser.currentUser()?.setValue(name, forKey: "firstName")
                        }
                    }
                    if let fbid = dict["id"] {
                        print("facebook id: \(fbid)")
                        PFUser.currentUser()?.setValue(fbid, forKey: "facebook_id")
                        
                        if PFUser.currentUser()?.objectForKey("photoUrl") == nil {
                            let url = "https://graph.facebook.com/v2.5/\(fbid)/picture?type=large&return_ssl_resources=1&width=1125"
                            PFUser.currentUser()?.setObject(url, forKey: "photoUrl")
                        }
                    }
                    PFUser.currentUser()?.saveInBackground()
                }
            }
        }
        
        // Quickblox user
        guard let user = PFUser.currentUser(), userId = user.objectId else {
            self.simpleAlert("Could not log in", defaultMessage: "Invalid user id", error: nil, completion: nil)
            return
        }
        QBUserService.sharedInstance.loginQBUser(userId, completion: { (success, error) in
            if success {
                self.inTransitionToLogin = false
                self.performSegueWithIdentifier("GoToMain", sender: nil)
            }
            else {
                self.simpleAlert("Could not log in", defaultMessage: "There was a problem connecting to chat.",  error: error, completion: {
                    self.inTransitionToLogin = false
                    UserService.logout()
                })
            }
        })
    }
    
    // MARK: SettingsDelegate
    func didLogout() {
        self.inTransitionToLogin = false
        self.dismissViewControllerAnimated(false) { () -> Void in
            self.goToLogin()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToMain" {
            /*
            let nav: UINavigationController = segue.destinationViewController as! UINavigationController
            let controller: HereAndNowViewController = nav.viewControllers[0] as! HereAndNowViewController
            controller.delegate = self
            */
        }
    }
}
