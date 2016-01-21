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
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var progressView: ProgressView!

    var category: String?
    var matches: [PFObject]?
    var requestedMatch: PFObject?
    var isQuerying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.progressView.startActivity()
        if self.requestedMatch != nil {
            let categories = self.requestedMatch!.valueForKey("categories") as! [String]
            self.category = categories[0]
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .Done, target: self, action: "cancel")
        }
        else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
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
            self.labelTitle.text = "Waiting for match"
            self.labelDetails.text = "You are waiting for someone else to join you for \(self.category!). Click Back to cancel and search for something else."
            // TODO: display location, time, other parameters
        }
        else {
            self.labelTitle.text = "Loading"
            self.labelDetails.text = "Please be patient..."
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
    
    // MARK: - API calls
    func queryForMatches() {
        // searches for existing requests for category. Does not create own request
        var categories: [String] = []
        if self.category != nil {
            categories = [self.category!]
        }
        self.isQuerying = true
        MatchRequest.queryMatches(nil, categories: categories) { (results, error) -> Void in
            self.progressView.stopActivity()
            self.isQuerying = false
            if results != nil {
                if results!.count == 0 {
                    if self.requestedMatch == nil {
                        self.createMatch()
                    }
                    self.refresh()
                    return
                }
                else {
                    self.matches = results
                    self.labelTitle.text = "Match found"
                    self.performSegueWithIdentifier("GoToMatches", sender: nil)
                }
            }
            else {
                let message = "There was a problem loading matches."
                self.simpleAlert("Could not load matches", defaultMessage: message, error: error)
                self.labelTitle.text = "Problem loading matches"
            }
            self.refresh()
        }
    }
    
    func createMatch() {
        // no existing requests exist. Create a request for others to match to
        self.labelTitle.text = "Waiting for a match"
        var categories: [String] = []
        if self.category != nil {
            categories = [self.category!]
        }
        self.progressView.startActivity()
        MatchRequest.createMatch(categories) { (result, error) -> Void in
            self.progressView.stopActivity()
            if result != nil {
                let match: PFObject = result! as PFObject
                self.requestedMatch = match
            }
            else {
                let message = "There was a problem setting up your activity."
                self.simpleAlert("Could not find matches", defaultMessage: message, error: error)
                self.labelTitle.text = "Problem creating activity"
            }
            self.refresh()
        }
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
        }
    }

}
