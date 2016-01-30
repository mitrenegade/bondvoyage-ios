//
//  MatchStatusViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class MatchStatusViewController: UIViewController, UserDetailsDelegate {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var progressView: ProgressView!

    var requestedMatch: PFObject? // the user's created bond request
    var fromMatch: PFObject? // another user who has invited this user
    var toMatch: PFObject? // user's invited bond request if coming from inviteViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let index = arc4random_uniform(5) + 1
        let name = "bg\(index)"
        self.bgImage.image = UIImage(named: name)!
        let blurEffect = UIBlurEffect(style: .Light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        var frame = self.bgImage.bounds
        frame.size.height += 20
        blurredEffectView.frame = frame
        blurredEffectView.alpha = 0.8
        self.bgImage.addSubview(blurredEffectView)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: self, action: "cancel")

        self.progressView.startActivity()
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        // refresh ui
        if self.toMatch != nil {
            // invited - waiting for bond acceptance
            self.labelTitle.text = "Waiting for user to accept the bond"
            self.labelDetails.text = "You are waiting for someone to accept your bond invitation."
            let category: String = (self.toMatch!.objectForKey("categories") as! [String])[0]
            if let user: PFUser = self.toMatch!.objectForKey("user") as? PFUser {
                user.fetchInBackgroundWithBlock({ (object, error) -> Void in
                    if let name: String = user.objectForKey("firstName") as? String {
                        self.labelTitle.text = "Waiting for \(name) to accept"
                        self.labelDetails.text = "You are waiting for \(name) to accept your invitation to bond over \(category)."
                    }
                })
            }
            // TODO: display location, time, other parameters
        }
        else if self.fromMatch != nil {
            if self.fromMatch!.valueForKey("status") as? String == "pending" {
                self.labelTitle.text = "You have received an invitation to bond"
                self.labelDetails.text = "Loading invitation details."
            }
            else if self.fromMatch!.valueForKey("status") as? String == "declined" {
                self.labelTitle.text = "Your invitation was declined"
                self.labelDetails.text = "Sorry, looks like this bond will not be accepted."
                self.progressView.stopActivity()
            }
            else if self.fromMatch!.valueForKey("status") as? String == "accepted" {
                self.goToPlaces()
                return
            }
            else if self.fromMatch!.valueForKey("status") as? String == "cancelled" {
                // handles a corner case where match was cancelled but the invited match was not
                self.labelTitle.text = "Your last bond has been cancelled"
                self.labelDetails.text = "Please hit back to search for more activities."
                self.progressView.stopActivity()
                return
            }
            let category: String = (self.fromMatch!.objectForKey("categories") as! [String])[0]
            
            if let user: PFUser = self.fromMatch!.objectForKey("user") as? PFUser {
                user.fetchInBackgroundWithBlock({ (object, error) -> Void in
                    if self.fromMatch!.valueForKey("status") as? String == "pending" {
                        if let name: String = user.objectForKey("firstName") as? String {
                            self.labelTitle.text = "You have received an invitation from \(name)"
                            self.labelDetails.text = "\(name) wants to bond over \(category)"
                        }
                        self.goToAcceptInvite(user)
                    }
                    else if self.fromMatch!.valueForKey("status") as? String == "declined" {
                        if let name: String = user.objectForKey("firstName") as? String {
                            self.labelTitle.text = "Your invitation was declined"
                            self.labelDetails.text = "Sorry, looks like \(name) declined your invitation to bond over \(category)."
                        }
                    }
                })
            }
        }
        else if self.requestedMatch != nil {
            // comes from SearchCategoryViewController
            if self.requestedMatch!.objectForKey("inviteTo") != nil {
                // user has invited someone
                self.labelTitle.text = "Waiting for user to accept the bond"
                self.labelDetails.text = "You are waiting for someone to accept your bond invitation."
                
                if let invited: PFObject = self.requestedMatch!.objectForKey("inviteTo") as? PFObject {
                    self.toMatch = invited
                    self.toMatch!.fetchInBackgroundWithBlock({ (object, error) -> Void in
                        if object != nil {
                            self.refresh()
                        }
                    })
                }
            }
            else if self.requestedMatch!.objectForKey("inviteFrom") != nil {
                // user has been invited by someone
                self.labelTitle.text = "You have received an invitation to bond"
                self.labelDetails.text = "Loading invitation details."
                if let inviteFrom: PFObject = self.requestedMatch!.objectForKey("inviteFrom") as? PFObject {
                    self.fromMatch = inviteFrom
                    self.fromMatch!.fetchInBackgroundWithBlock({ (object, error) -> Void in
                        if object != nil {
                            self.refresh()
                        }
                    })
                }
            }
            else {
                let category: String = (self.requestedMatch!.objectForKey("categories") as! [String])[0]
                self.labelTitle.text = "No bonds available"
                self.labelDetails.text = "You are waiting for someone else to join you for \(category). Click Back to cancel and search for something else."
            }
        }
        else {
            print("No matches to display in MatchStatusViewController: error!")
            self.close()
        }
    }
    
    func cancel() {
        if self.toMatch != nil {
            self.cancelInvitation()
        }
        else if self.fromMatch != nil && self.requestedMatch == nil {
            // hack: handle a case where the inviting match was cancelled but invited match was not
            self.requestedMatch = self.fromMatch
            self.cancelMatch()
        }
        else {
            self.cancelMatch()
        }
    }
    
    func close() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func goToMatches() {
        self.performSegueWithIdentifier("GoToMatches", sender: nil)
    }

    func goToPlaces() {
        let categories: [String] = self.fromMatch!.objectForKey("categories") as! [String]
        let controller: PlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("placesID") as! PlacesViewController
        controller.relevantInterests = categories
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func cancelInvitation() {
        MatchRequest.respondToInvite(self.requestedMatch!, toMatch: self.toMatch!, responseType: "cancelled") { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not cancel invitation", defaultMessage: "Your current invitation could not be cancelled", error: error)
            }
            else {
                self.close()
            }
        }
    }
    
    func cancelMatch() {
        // todo: handle corner case: user has requested a match but does not receive notifications.
        // that match gets an invitation. But before they reload the match they cancel it.
        // need to check if requestedMatch has an invite already, and cancelInvitation instead.
        
        MatchRequest.cancelMatch(self.requestedMatch!) { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not cancel match", defaultMessage: "Your current match could not be cancelled", error: error)
            }
            else {
                self.close()
            }
        }
    }
    
    func goToAcceptInvite(user: PFUser) {
        let controller: UserDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("userDetailsID") as! UserDetailsViewController
        controller.invitingUser = user
        controller.invitingMatch = self.fromMatch
        controller.delegate = self
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    // MARK: - UserDetailsDelegate
    func didDeclineInvitation() {
        self.fromMatch = nil
        // fetch from web because it was already updated
        self.requestedMatch?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.refresh()
        })
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
