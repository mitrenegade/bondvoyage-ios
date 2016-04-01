//
//  MatchStatusViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView

class MatchStatusViewController: UIViewController, UserDetailsDelegate {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var progressView: ProgressView!

    @IBOutlet weak var viewInvitation: UIView!
    @IBOutlet weak var photoView: AsyncImageView!
    @IBOutlet weak var labelInvitation: UILabel!
    @IBOutlet weak var constraintInvitationHeight: NSLayoutConstraint!

    var user: PFUser!
    var currentActivity: PFObject? // the user's created bond request
    var blurAdded: Bool = false
    var locationString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let index = arc4random_uniform(5) + 1
        let name = "bg\(index)"
        self.bgImage.image = UIImage(named: name)!
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: self, action: "cancel")
        
        self.constraintInvitationHeight.constant = 0

        self.progressView.startActivity()
        self.user = self.currentActivity!.objectForKey("user") as! PFUser
        user.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.labelTitle.hidden = false
            self.labelDetails.hidden = false
            self.refresh()
        })
        
        if let geopoint: PFGeoPoint = self.currentActivity!.objectForKey("geopoint") as? PFGeoPoint {
            self.reverseGeocode(CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.blurAdded {
            self.blurAdded = true
            let blurEffect = UIBlurEffect(style: .Light)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            var frame = self.bgImage.bounds
            frame.size.height += 20
            blurredEffectView.frame = frame
            blurredEffectView.alpha = 0.8
            self.bgImage.addSubview(blurredEffectView)
        }
    }
    
    func refresh() {
        // refresh ui
        if self.user != PFUser.currentUser() {
            // join request sent - waiting for bond acceptance
            self.labelTitle.text = "Waiting for user to accept the bond"
            self.labelDetails.text = "You are waiting for someone to accept your bond invitation."
            let category: String = (self.currentActivity!.objectForKey("categories") as! [String])[0]
            if let name: String = user.objectForKey("firstName") as? String {
                self.labelTitle.text = "Waiting for \(name) to accept"
                self.labelDetails.text = "You are waiting for \(name) to accept your invitation to bond over \(category)."
            }
            // TODO: display location, time, other parameters
        }
        else {
            let category: String = (self.currentActivity!.objectForKey("categories") as! [String])[0]
            // general info
            self.labelTitle.text = "Activities for \(category)"
            if self.locationString != nil {
                self.labelTitle.text = "Activities for \(category) near \(self.locationString!)"
            }
            self.labelDetails.text = "You are waiting for someone else to join you for \(category). Click Back to cancel and search for something else."

            if self.currentActivity!.valueForKey("status") as? String == "pending" {
                self.labelDetails.text = "You have received an invitation to bond. Click on each user to accept their bond, or click Back to cancel."
                self.labelInvitation.text = "Loading invitation details."
                self.constraintInvitationHeight.constant = 81
                
                // join requests exist
                if let userIds: [String] = self.currentActivity!.objectForKey("joining") as? [String] {
                    let userId = userIds[0]
                    let query: PFQuery = PFUser.query()!
                    query.whereKey("objectId", equalTo: userId)
                    query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                        if results != nil && results!.count > 0 {
                            let user: PFUser = results![0] as! PFUser
                            if let name: String = user.objectForKey("firstName") as? String {
                                self.labelInvitation.text = "\(name) wants to bond over \(category)"
                            }
                            
                            if let photoURL: String = user.objectForKey("photoUrl") as? String {
                                self.photoView.imageURL = NSURL(string: photoURL)
                            }
                            
                            // TODO: goToAccept when clicked
                            //                        self.goToAcceptInvite(user)
                        }
                    }
                }
            }
            else if self.currentActivity!.valueForKey("status") as? String == "declined" {
                /* TODO - cannot come here. If invitation is declined, it becomes active
                self.labelTitle.text = "Your invitation was declined"
                self.labelDetails.text = "Sorry, looks like this bond will not be accepted."
                */
                self.progressView.stopActivity()
            }
            else if self.currentActivity!.valueForKey("status") as? String == "accepted" {
                /* TODO: display suggested places from other user */
                self.goToPlaces()
                return
            }
            else if self.currentActivity!.valueForKey("status") as? String == "cancelled" {
                // handles a corner case where match was cancelled but the invited match was not
                self.labelTitle.text = "Your last bond has been cancelled"
                self.labelDetails.text = "Please hit back to search for more activities."
                self.progressView.stopActivity()
                return
            }
        }
    }
    
    func reverseGeocode(coord: CLLocation) {
        let coder = CLGeocoder()
        coder.reverseGeocodeLocation(coord) { (results, error) -> Void in
            if error != nil {
                print("error: \(error!.userInfo)")
            }
            else {
                print("result: \(results)")
                if let placemarks: [CLPlacemark]? = results as [CLPlacemark]? {
                    if let placemark: CLPlacemark = placemarks!.first as CLPlacemark! {
                        print("name \(placemark.name) address \(placemark.addressDictionary)")
                        if let dict: [String: AnyObject] = placemark.addressDictionary as? [String: AnyObject] {
                            if let lines = dict["FormattedAddressLines"] as? [String] {
                                print("lines: \(lines)")
                                if lines.count > 0 {
                                    self.locationString = lines[0]
                                }
                                self.refresh()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func cancel() {
        self.cancelMatch()
    }
    
    func close() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func goToMatches() {
        self.performSegueWithIdentifier("GoToMatches", sender: nil)
    }

    func goToPlaces() {
        let categories: [String] = self.currentActivity!.objectForKey("categories") as! [String]
        let controller: PlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("PlacesViewController") as! PlacesViewController
        controller.relevantInterests = categories
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func cancelInvitation() {
        // TODO
        /*
        MatchRequest.respondToInvite(self.requestedMatch!, toMatch: self.toMatch!, responseType: "cancelled") { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not cancel invitation", defaultMessage: "Your current invitation could not be cancelled", error: error)
            }
            else {
                self.close()
            }
        }
        */
    }
    
    func cancelMatch() {
        // todo: handle corner case: user has requested a match but does not receive notifications.
        // that match gets an invitation. But before they reload the match they cancel it.
        // need to check if requestedMatch has an invite already, and cancelInvitation instead.
        
        ActivityRequest.cancelActivity(self.currentActivity!) { (results, error) -> Void in
            if error != nil {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Could not cancel activity", message: "You were logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                    })
                    return
                }
                self.simpleAlert("Could not cancel activity", defaultMessage: "Your current activity could not be cancelled", error: error)
            }
            else {
                self.close()
            }
        }
    }
    
    func goToAcceptInvite(user: PFUser) {
        let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
        controller.invitingUser = user
        controller.invitingActivity = self.currentActivity
        controller.delegate = self
        controller.title = "Invite"
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    // MARK: - UserDetailsDelegate
    func didRespondToInvitation() {
        /* TODO
        self.fromMatch = nil
        // fetch from web because it was already updated
        self.requestedMatch?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            self.refresh()
        })
        */
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
