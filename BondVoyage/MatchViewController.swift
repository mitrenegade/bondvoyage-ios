//
//  MatchViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class MatchViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var buttonUp: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    var didSetupScroll: Bool = false
    
    var category: String?
    var matches: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didSetupScroll {
            didSetupScroll = true
            self.setupScroll()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickButton(button: UIButton) {
        if button == self.buttonUp {
            // create a bond
        }
    }
    
    func setupScroll() {
        if self.matches == nil {
            return
        }

        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = self.scrollView.frame.size.height
        self.scrollView.pagingEnabled = true

        for var i=0; i<self.matches!.count; i++ {
            let match = self.matches![i]
            let user = match.objectForKey("user") as! PFUser
            let controller: UserDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("userDetailsID") as! UserDetailsViewController
            controller.selectedUser = user
            
            controller.willMoveToParentViewController(self)
            self.addChildViewController(controller)
            self.scrollView.addSubview(controller.view)
            let frame = CGRectMake(width * CGFloat(i), 0, width, height)
            controller.view.frame = frame
            controller.didMoveToParentViewController(self)
        }
        self.scrollView.contentSize = CGSizeMake(CGFloat(self.matches!.count) * width, height)
    }
    
    func refresh() {
        if self.matches == nil {
            self.buttonUp.hidden = true
        }
        else if self.matches!.count == 0 {
            self.buttonUp.hidden = true
        }
        else {
            self.buttonUp.hidden = false
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
