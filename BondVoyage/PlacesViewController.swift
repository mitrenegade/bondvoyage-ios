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
    
    @IBOutlet weak var mapView: GMSMapView!
    var place: BVPlace!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var recommendations: [PFObject]?
    var relevantInterests: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.scrollView.contentSize.height = 1000
        
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
            self.place!.fetchImage({ (image) -> Void in
                if (image != nil) {
                    self.imageView.image = image
                }
            })
        }
        
        self.placeNameLabel.text = self.place.name
        self.addressLabel.text = self.place.address
        
        self.aboutPlaceLabel.text = self.place.shortDescription as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
