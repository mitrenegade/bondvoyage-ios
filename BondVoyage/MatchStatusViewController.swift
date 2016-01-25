//
//  MatchStatusViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class MatchStatusViewController: UIViewController {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var progressView: ProgressView!

    var category: String?
    var fromMatch: PFObject? // the user's created bond request
    var toMatch: PFObject? // the user's invited bond request if coming from inviteViewController
    
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
            if let user: PFUser = self.toMatch!.objectForKey("user") as? PFUser {
                user.fetchInBackgroundWithBlock({ (object, error) -> Void in
                    if let name: String = user.objectForKey("firstName") as? String {
                        self.labelTitle.text = "Waiting for \(name) to accept"
                        self.labelDetails.text = "You are waiting for \(name) to accept your invitation to bond over \(self.category!)."
                    }
                })
            }
            // TODO: display location, time, other parameters
        }
        else if self.fromMatch != nil && self.fromMatch!.objectForKey("inviteTo") != nil {
            self.labelTitle.text = "Waiting for user to accept the bond"
            self.labelDetails.text = "You are waiting for someone to accept your bond invitation."
            
            if let invited: PFObject = self.fromMatch!.objectForKey("inviteTo") as? PFObject {
                self.toMatch = invited
                self.toMatch!.fetchInBackgroundWithBlock({ (object, error) -> Void in
                    if object != nil {
                        self.refresh()
                    }
                })
            }
        }

        else {
            self.labelTitle.text = "No bonds available"
            self.labelDetails.text = "You are waiting for someone else to join you for \(self.category!). Click Back to cancel and search for something else."
        }
    }
    
    func cancel() {
        if self.toMatch != nil {
            self.cancelInvitation()
        }
        else {
            self.cancelMatch()
        }
    }
    
    func close() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func goToMatches() {
        self.performSegueWithIdentifier("GoToMatches", sender: nil)
    }

    func cancelInvitation() {
        MatchRequest.cancelInvite(self.fromMatch!, toMatch: self.toMatch!) { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not cancel invitation", defaultMessage: "Your current invitation could not be cancelled", error: error)
            }
            else {
                self.close()
            }
        }
    }
    
    func cancelMatch() {
        MatchRequest.cancelMatch(self.fromMatch!) { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not cancel match", defaultMessage: "Your current match could not be cancelled", error: error)
            }
            else {
                self.close()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
