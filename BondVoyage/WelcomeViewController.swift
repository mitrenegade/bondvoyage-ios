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
            self.didLogin()
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
        self.performSegueWithIdentifier("GoToMain", sender: nil)
        let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        request.startWithCompletionHandler { (connection, result, error) -> Void in
            print("\(result) \nerror: \(error)")
            if result != nil {
                if let name = result["name"] as? String {
                    print("name: \(name)")
                    if PFUser.currentUser()?.objectForKey("firstName") == nil {
                        PFUser.currentUser()?.setValue(name, forKey: "firstName")
                    }
                }
                if let fbid = result["id"] as? String {
                    print("facebook id: \(fbid)")
                    PFUser.currentUser()?.setValue(fbid, forKey: "facebook_id")
                    
                    if PFUser.currentUser()?.objectForKey("photoUrl") == nil {
                        let url = "https://graph.facebook.com/\(fbid)/picture?type=large&return_ssl_resources=1"
                        PFUser.currentUser()?.setObject(url, forKey: "photoUrl")
                    }
                }
                PFUser.currentUser()?.saveInBackground()
            }
        }
    }
    
    // MARK: SettingsDelegate
    func didLogout() {
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
