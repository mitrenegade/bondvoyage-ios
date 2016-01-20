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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadMatches()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Query
    func loadMatches() {
        self.labelTitle.text = "Searching for matches"
        self.progressView.startActivity()
        
        var categories: [String] = []
        if self.category != nil {
            categories = [self.category!]
        }
        
        MatchRequest.queryMatches(nil, categories: categories) { (results, error) -> Void in
            self.progressView.stopActivity()
            if results != nil {
                if results!.count == 0 {
                    self.createMatch()
                    return
                }
                else {
                    self.matches = results
                    self.performSegueWithIdentifier("GoToMatches", sender: nil)
                }
            }
            else {
                let message = "There was a problem loading matches."
                self.simpleAlert("Could not load matches", defaultMessage: message, error: error)
                self.labelTitle.text = "Problem loading matches"
            }
        }
    }
    
    func createMatch() {
        self.labelTitle.text = "Waiting for a match"
        var categories: [String] = []
        if self.category != nil {
            categories = [self.category!]
        }
        self.progressView.startActivity()
        MatchRequest.createMatch(categories) { (results, error) -> Void in
            if results != nil {
                print("Created \(results!.count) matches")
            }
            else {
                self.progressView.stopActivity()
                let message = "There was a problem setting up your activity."
                self.simpleAlert("Could not find matches", defaultMessage: message, error: error)
                self.labelTitle.text = "Problem creating activity"
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
