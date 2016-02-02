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
        bgImage = UIImageView(image: UIImage(named: "bg6"))
        bgImage.contentMode = .ScaleAspectFill
        self.logInView!.insertSubview(bgImage, atIndex: 0)
        
        logoView = UIImageView(image: UIImage(named: "logo-plain"))
        logoView.contentMode = .ScaleAspectFit
        
        logInView?.logInButton?.setBackgroundImage(nil, forState: .Normal)
        logInView?.logInButton?.backgroundColor = Constants.blueColor()
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        logInView?.signUpButton?.setBackgroundImage(nil, forState: .Normal)
        logInView?.signUpButton?.backgroundColor = Constants.blueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        bgImage.frame = CGRectMake( 0,  0,  self.logInView!.frame.width,  self.logInView!.frame.height)
        
        var height = self.view.frame.size.height / 6
        var y = logInView!.usernameField!.frame.origin.y - height - 16
        if y < 0 {
            y = 0
            height = logInView!.usernameField!.frame.origin.y - 8
        }
        let frame = CGRectMake(0, y, logInView!.frame.width,  height)
        logInView!.logo = logoView
        logInView!.logo?.frame = frame
    }
    
    func customizeButton(button: UIButton!) {
        button.setBackgroundImage(nil, forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
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
