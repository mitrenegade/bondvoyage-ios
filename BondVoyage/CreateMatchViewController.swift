//
//  CreateMatchViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class CreateMatchViewController: UIViewController {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var progressView: ProgressView!

    var category: String?
    var matches: [PFObject]?
    var requestedMatch: PFObject?
    var isQuerying: Bool = false
    
    weak var inviteController: InviteViewController?
    
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
        
        self.progressView.startActivity()
        if self.requestedMatch != nil {
            let categories = self.requestedMatch!.valueForKey("categories") as! [String]
            self.category = categories[0]
            self.inviteController?.fromMatch = self.requestedMatch
        }
        else {
            // always create a match if one doesn't already exist
            self.createMatch()
        }
        
        self.queryForMatches()
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        // refresh ui
        if self.isQuerying {
            self.labelTitle.text = "Searching for \(self.category!)"
            self.labelDetails.text = "Looking for someone else who is also down for \(self.category!)"
        }
        else if self.requestedMatch != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: self, action: "cancel")

            self.labelTitle.text = "Waiting for match"
            self.labelDetails.text = "You are waiting for someone else to join you for \(self.category!). Click Back to cancel and search for something else."
            // TODO: display location, time, other parameters
        }
        else {
            self.labelTitle.text = "Loading"
            self.labelDetails.text = "Please be patient..."
        }
        
        if self.matches != nil && self.matches!.count > 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "View Matches", style: .Done, target: self, action: "goToMatches")
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func cancel() {
        let alert: UIAlertController = UIAlertController(title: "Stop waiting?", message: "Would you like to cancel and search for something else?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Back to categories", style: .Default, handler: { (action) -> Void in
            self.cancelMatch()
        }))
        alert.addAction(UIAlertAction(title: "Keep waiting", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func close() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func goToMatches() {
        self.performSegueWithIdentifier("GoToMatches", sender: nil)
    }
    
    func cancelMatch() {
        MatchRequest.cancelMatch(requestedMatch!) { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not cancel match", defaultMessage: "Your current match could not be cancelled", error: error)
            }
            else {
                self.simpleAlert("Match canceled", message: "Click Close to find another match", completion: { () -> Void in
                    self.close()
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToMatches" {
            let controller: MatchViewController = segue.destinationViewController as! MatchViewController
            controller.category = self.category
            controller.matches = self.matches
            controller.fromMatch = self.requestedMatch
            self.matchController = controller
        }
    }

}
