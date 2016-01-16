//
//  PlacesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/16/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView
import Parse

class PlacesViewController: UIViewController {
    
    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var buttonGo: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var recommendations: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadRecommendation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Query
    func loadRecommendation() {
        // HACK: load any recommendation
        self.activityIndicator.startAnimating()
        RecommendationRequest.recommendationsQuery(nil, interests: []) { (results, error) -> Void in
            self.activityIndicator.stopAnimating()
            if results != nil {
                self.recommendations = results
                self.refresh()
            }
            else {
                let message = "No recommendations are available for your bond."
                self.simpleAlert("Could not load recommendations", defaultMessage: message, error: error)
            }
        }
    }
    
    func nextRecommendation() {
        if self.recommendations == nil || self.recommendations!.count == 0 {
            self.noMoreRecommendations()
        }
        if self.recommendations?.count > 0 {
            self.recommendations!.removeFirst()
            self.refresh()
        }
    }
    
    func noMoreRecommendations() {
        self.simpleAlert("No more recommendations", defaultMessage: "We are out of recommendations. Tough luck!", error: nil)
    }

    // MARK: - Display
    func refresh() {
        let recommendation: PFObject = self.recommendations!.first!
        if let url: String = recommendation.objectForKey("imageURL") as? String {
            self.imageView.imageURL = NSURL(string: url)
        }
        else if let image: PFFile = recommendation.objectForKey("image") as? PFFile {
            self.imageView.imageURL = NSURL(string: image.url!)
        }

        var text: String = ""
        if let title: String = recommendation.objectForKey("name") as? String {
            text = title
        }
        if let description: String = recommendation.objectForKey("description") as? String {
            text = "\(text)\n\n\(description)"
        }
        self.labelInfo.text = text
    }

    // MARK: - Action
    @IBAction func didClickButton(button: UIButton) {
        if button == self.buttonGo {
            print("Go")
        }
        else if button == self.buttonNext {
            print("Next")
            self.nextRecommendation()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
