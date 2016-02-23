//
//  InviteViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class InviteViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    var didSetupScroll: Bool = false
    
    var category: String?
    var matches: [PFObject]?
    var fromMatch: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: "cancel")
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
    
    func cancel() {
        MatchRequest.cancelMatch(self.fromMatch!) { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not cancel match", defaultMessage: "Your current match could not be cancelled", error: error)
            }
            else {
                self.navigationController!.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    @IBAction func didClickButton(button: UIButton) {
        if button == self.buttonUp {
            // create a bond
            if self.fromMatch != nil {
                self.goToSelectPlace()
            }
            else {
                self.simpleAlert("Please try again", defaultMessage: "You aren't currently looking for a match. Please go back and select a category.", error: nil)
            }
        }
    }
        
    func currentPage() -> Int {
        let page = Int(floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width))
        return page
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
            controller.configureUI() // force resize
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
    
    func goToMatchStatus() {
        self.activityIndicator.startAnimating()
        MatchRequest.inviteMatch(self.fromMatch!, toMatch: self.matches![self.currentPage()], completion: { (results, error) -> Void in
            self.activityIndicator.stopAnimating()
            if error != nil {
                self.simpleAlert("Could not invite", defaultMessage: "There was an error sending your invite.", error: error)
            }
            else {
                self.performSegueWithIdentifier("GoToMatchStatus", sender: self)
            }
        })
    }
    
    func goToSelectPlace() {
        let controller: SuggestedPlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("SuggestedPlacesViewController") as! SuggestedPlacesViewController
        let categories: [String] = self.fromMatch!.objectForKey("categories") as! [String]
        controller.relevantInterest = categories[0]
        self.navigationController?.pushViewController(controller, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToMatchStatus" {
            let controller: MatchStatusViewController = segue.destinationViewController as! MatchStatusViewController
            controller.requestedMatch = self.fromMatch
            controller.toMatch = self.matches![self.currentPage()]
        }
    }
}
