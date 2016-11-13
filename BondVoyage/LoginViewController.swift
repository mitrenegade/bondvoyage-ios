//
//  LoginViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import ParseUI

class LoginViewController: PFLogInViewController {

    var bgImage: UIImageView!
    var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bgImage = UIImageView(image: UIImage(named: "bondVoyageBackground"))
        bgImage.contentMode = .scaleAspectFill
        bgImage.backgroundColor = UIColor.clear
        self.logInView!.insertSubview(bgImage, at: 0)
        
        logoView = UIImageView(image: UIImage(named: "logo-plain"))
        logoView.contentMode = .scaleAspectFit
        
        logInView?.logInButton?.setBackgroundImage(nil, for: UIControlState())
        logInView?.logInButton?.backgroundColor = Constants.blueColor()
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.black, for: UIControlState())
        logInView?.signUpButton?.setBackgroundImage(nil, for: UIControlState())
        logInView?.signUpButton?.backgroundColor = Constants.blueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.customizeLayout()
    }
    
    func customizeLayout() {
        // stretch background image to fill screen
        //bgImage.frame = CGRectMake( 0,  0,  self.logInView!.frame.width,  self.logInView!.frame.height)
        var height = self.view.frame.size.height / 6
        var y = logInView!.usernameField!.frame.origin.y - height - 16
        if y < 20 {
            y = 20
            height = logInView!.usernameField!.frame.origin.y - 8
        }
        var frame = CGRect(x: 0, y: y, width: logInView!.frame.width,  height: height)
        logInView!.logo = logoView
        logInView!.logo?.frame = frame
        
        // background image
        let ratio = CGFloat(847.0 / 1437.0)
        frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width * ratio)
        frame.origin.y = logInView!.logo!.frame.origin.y + logInView!.logo!.frame.size.height
        bgImage.frame = frame
        
        // facebook
        frame = self.logInView!.facebookButton!.frame
        frame.origin.x = -5
        frame.size.width = self.view.frame.size.width + 10
        frame.origin.y = bgImage.frame.origin.y + bgImage.frame.size.height
        if self.view.frame.size.height == 480 {
            // iphone 4 - HACK make it fit
            frame.origin.y = frame.origin.y - 5
        }
        self.logInView!.facebookButton!.frame = frame
        self.logInView!.facebookButton!.layer.cornerRadius = 0
        
        // username input
        frame = self.logInView!.usernameField!.frame
        frame.origin.y = self.logInView!.facebookButton!.frame.origin.y + self.logInView!.facebookButton!.frame.size.height + 8
        self.logInView!.usernameField!.frame = frame
        
        // password input
        frame = self.logInView!.passwordField!.frame
        frame.origin.y = self.logInView!.usernameField!.frame.origin.y + self.logInView!.usernameField!.frame.size.height
        self.logInView!.passwordField!.frame = frame
        
        // password
        frame = self.logInView!.passwordForgottenButton!.frame
        frame.origin.y = self.logInView!.passwordField!.frame.origin.y + self.logInView!.passwordField!.frame.size.height + 8
        if self.view.frame.size.height == 480 {
            // iphone 4 - HACK make it fit
            frame.size.height = frame.size.height - 10
        }
        self.logInView!.passwordForgottenButton!.frame = frame
        
        frame = self.logInView!.logInButton!.frame
        frame.size.width = frame.size.width / 2 - 1
        if self.view.frame.size.height == 480 {
            // iphone 4 - HACK make it fit
            frame.size.height = frame.size.height - 10
        }
        frame.origin.y = self.logInView!.passwordForgottenButton!.frame.origin.y + self.logInView!.passwordForgottenButton!.frame.size.height + 8
        self.logInView!.logInButton!.frame = frame
        frame.origin.x = frame.size.width + 1
        self.logInView!.signUpButton!.frame = frame
        
        
        /*
        let topView = self.logInView!.logInButton!
        let bottomView = self.logInView!.facebookButton!
        
        bgImage.frame = CGRectMake(0, topView.frame.origin.y + topView.frame.size.height, self.view.frame.size.width, bottomView.frame.origin.y - topView.frame.origin.y - topView.frame.size.height)
        */
        //}
    }
    
    func customizeButton(_ button: UIButton!) {
        button.setBackgroundImage(nil, for: UIControlState())
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
