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
import GoogleMaps

class PlacesViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var buttonGo: UIButton!
    @IBOutlet weak var buttonNext: UIButton!

    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var iconView: AsyncImageView!
    @IBOutlet weak var constraintIconWidth: NSLayoutConstraint!
    
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var placeNameLabel: UILabel!
    
    @IBOutlet var aboutPlaceLabel: UILabel!
    @IBOutlet weak var constraintAboutHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: GMSMapView!
    var place: BVPlace!
    var recommendations: [BVPlace]?
    var currentPage: Int = 0
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var relevantInterests: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.recommendations == nil {
            self.recommendations = [place]
        }
        else {
            self.currentPage = self.recommendations!.indexOf(self.place)!
        }
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        let coordinate = place.coordinate
        let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 10)
        self.mapView.camera = camera
        self.mapView.delegate = self
        
        if let iconURLString = self.place.iconURL {
            self.iconView.imageURL = NSURL(string: iconURLString)
            // for now no icon - should be something more business specific
            self.constraintIconWidth.constant = 0
        }
        
        if place.photo != nil {
            self.imageView.image = place.photo
        }
        else {
            // hack: if place exists, fetch the image from the photo reference
            // if place is nil and only a merchant exists, we fetch the details then use the photo reference to fetch the photos. we don't update any other aspect of the FVPlace
            self.imageView.image = nil
            self.imageView.startAnimating()
            self.place!.fetchImage({ (image) -> Void in
                if (image != nil) {
                    self.imageView.image = image
                }
                self.imageView.stopAnimating()
            })
        }
        
        self.placeNameLabel.text = self.place.name
        self.addressLabel.text = self.place.address
        
        if self.place.shortDescription != nil {
            self.aboutPlaceLabel.text = self.place.shortDescription as? String
        }
        else {
            self.constraintAboutHeight.constant = 0
        }
    }
    
    // MARK: - Action
    @IBAction func didClickButton(button: UIButton) {
        if button == self.buttonGo {
            print("Go")
            self.simpleAlert("You are all set", message: "You have accepted this invitation. Have a good time!", completion: { () -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        else if button == self.buttonNext {
            print("Next")
            if self.currentPage < self.recommendations!.count - 1 {
                self.currentPage = self.currentPage + 1
            }
            else {
                self.currentPage = 0
            }
            self.place = self.recommendations![self.currentPage]
            self.refresh()
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
