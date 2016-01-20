//
//  MatchViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var buttonDown: UIButton!
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var labelText: UILabel!

    @IBOutlet weak var containerUser: UIView!
    var userController: UserDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.containerUser.hidden = true
        self.progressView.startActivity()
        
        self.labelText.text = "Search for matches"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickButton(button: UIButton) {
        if button == self.buttonDown {
            
        }
        else if button == self.buttonUp {
            
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedUserDetails" {
            let controller: UserDetailsViewController = segue.destinationViewController as! UserDetailsViewController
            self.userController = controller
        }
    }
}
