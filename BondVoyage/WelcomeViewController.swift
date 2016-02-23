//
//  WelcomeViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import ParseUI

class WelcomeViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, SettingsDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            let nav: UINavigationController = segue.destinationViewController as! UINavigationController
            let controller: HereAndNowViewController = nav.viewControllers[0] as! HereAndNowViewController
            controller.delegate = self
        }
    }
}
