//
//  InviteViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import PKHUD

protocol InviteDelegate: class {
    func didCloseInvites(invited: Bool)
}

class InviteViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    var didSetupScroll: Bool = false
    
    var category: CATEGORY?
//    var activities: [PFObject]?
    var people: [PFUser]?
    var delegate: InviteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: #selector(close))
        self.configureRightNavigationButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didSetupScroll {
            didSetupScroll = true
            self.setupScroll()
        }
    }
    
    func configureRightNavigationButton() {
        let button = UIButton(frame: CGRectMake(0, 0, 40, 40))
        button.addTarget(self, action: #selector(didClickInviteOrChat), forControlEvents: .TouchUpInside)
        button.setImage(UIImage(named: "icon150"), forState: .Normal)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        if self.delegate != nil {
            self.delegate!.didCloseInvites(false)
        }
        else {
            self.navigationController!.popToRootViewControllerAnimated(true)
        }
    }
    
    func didClickInviteOrChat() {
        print("here")
    }
    
    func goToJoinActivity(activity: PFObject) {
        self.activityIndicator.startAnimating()
        HUD.show(.SystemActivity)
        ActivityRequest.joinActivity(activity, suggestedPlace: nil, completion: { (results, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            if error != nil {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to join activities.", completion: { () -> Void in
                        UserService.logout()
                    })
                    return
                }
                HUD.flash(.Label("There was an error joining the activity."), delay: 2)
            }
            else {
                self.refresh()
                HUD.show(.Label("Invitation sent."))
                HUD.hide(animated: true, completion: { (complete) -> Void in
                    if self.delegate != nil {
                        self.delegate!.didCloseInvites(true)
                    }
                    else {
                        self.navigationController!.popToRootViewControllerAnimated(true)
                    }
                })
            }
        })
    }

    func currentPage() -> Int {
        let page = Int(floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width))
        return page
    }
    
    func setupScroll() {
        guard let users = self.people else {
            return
        }

        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = self.scrollView.frame.size.height
        self.scrollView.pagingEnabled = true

        for i in 0 ..< users.count {
            //let activity = self.activities![i]
            let user = users[i]
            let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
            controller.selectedUser = user
            
            controller.willMoveToParentViewController(self)
            self.addChildViewController(controller)
            self.scrollView.addSubview(controller.view)
            let frame = CGRectMake(width * CGFloat(i), 0, width, height)
            controller.view.frame = frame
            controller.didMoveToParentViewController(self)
            controller.configureUI() // force resize
        }
        self.scrollView.contentSize = CGSizeMake(CGFloat(users.count) * width, height)
    }
    
    func refresh() {
        guard let users = self.people else {
            self.buttonUp.hidden = true
            return
        }
        
        if users.count == 0 {
            self.buttonUp.hidden = true
        }
        else {
            self.buttonUp.hidden = false
        }
    }
}
