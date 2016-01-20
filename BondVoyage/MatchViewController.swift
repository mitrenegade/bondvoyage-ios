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
    @IBOutlet weak var buttonDown: UIButton!
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var labelText: UILabel!

    @IBOutlet weak var containerUser: UIView!
    var userController: UserDetailsViewController!
    
    var category: String?
    
    var matches: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.containerUser.hidden = true
        
        self.labelText.text = "Search for matches"
        
        self.loadMatches()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickButton(button: UIButton) {
        if button == self.buttonDown {
            
        }
        else if button == self.buttonUp {
            
        }
    }
    
    func refresh() {
        if self.matches == nil {
            self.containerUser.hidden = true
        }
        else if self.matches!.count == 0 {
            self.containerUser.hidden = true
        }
        else {
            self.containerUser.hidden = false
        }
    }
    
    // MARK: - Query
    func loadMatches() {
        // HACK: load any recommendation
        self.progressView.startActivity()
        var categories: [String] = []
        if self.category != nil {
            categories = [self.category!]
        }
        MatchRequest.queryMatches(nil, categories: categories) { (results, error) -> Void in
            self.progressView.stopActivity()
            if results != nil {
                if results!.count == 0 {
                    self.promptForCreateMatch()
                    return
                }
                else {
                    self.matches = results
                    self.refresh()
                }
            }
            else {
                let message = "There was a problem loading matches."
                self.simpleAlert("Could not load matches", defaultMessage: message, error: error)
            }
        }
    }
    
    func promptForCreateMatch() {
        self.simpleAlert("No matches", message: "No matches currently exist for \(self.category!)", completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedUserDetails" {
            let controller: UserDetailsViewController = segue.destinationViewController as! UserDetailsViewController
            self.userController = controller
        }
    }
}
