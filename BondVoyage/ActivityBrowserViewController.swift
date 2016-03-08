//
//  ActivityBrowserViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class ActivityBrowserViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var didSetupScroll: Bool = false
    
    var category: String?
    var activities: [PFObject]?
    var currentActivity: PFObject?
    var isRequestingJoin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "close")
        self.title = "Invite"
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
    
    func close() {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func currentPage() -> Int {
        let page = Int(floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width))
        return page
    }
    
    func setupScroll() {
        if self.activities == nil {
            return
        }

        //var frame = self.view.frame
        //frame.origin.y = 0
        //self.scrollView = UIScrollView(frame: frame)
        //self.view.addSubview(self.scrollView)
        
        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = self.scrollView.frame.size.height
        self.scrollView.pagingEnabled = true

        var currentOffset: CGFloat = 0
        for var i=0; i<self.activities!.count; i++ {
            let activity = self.activities![i]
            let controller: ActivityDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ActivityDetailViewController") as! ActivityDetailViewController
            controller.isRequestingJoin = self.isRequestingJoin
            controller.activity = activity
            
            controller.browser = self
            
            controller.willMoveToParentViewController(self)
            self.addChildViewController(controller)
            self.scrollView.addSubview(controller.view)
            let frame = CGRectMake(width * CGFloat(i), 0, width, height)
            controller.view.frame = frame
            controller.didMoveToParentViewController(self)
            
            if activity == self.currentActivity {
                currentOffset = CGFloat(i) * width
            }
        }
        self.scrollView.contentSize = CGSizeMake(CGFloat(self.activities!.count) * width, height)
        self.scrollView.contentOffset = CGPointMake(currentOffset, 0)
    }
    
    func didSendInvitationForPlace() {
        // not a delegate call but direct call by ActivityDetail
        self.navigationController?.popToViewController(self, animated: true)
    }
}
