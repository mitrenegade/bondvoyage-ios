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
import PKHUD

protocol InvitationDelegate {
    func didSendInvitationForPlace()
    func didAcceptInvitationForPlace()
}

class PlacesViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var buttonGo: UIButton!
    @IBOutlet weak var buttonNext: UIButton!

    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var constraintImageHeight: NSLayoutConstraint!
    
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
    var marker: GMSMarker!
    var currentActivity: PFObject?
    
    var isRequestingJoin: Bool = false // true if the user is suggesting this place as part of an invitation
    var isRequestedJoin: Bool = false // true if the user has already suggested this place
    
    var delegate: InvitationDelegate?
    
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
        
        if self.isRequestingJoin {
            self.buttonGo.setTitle("SEND INVITATION TO BOND", forState: .Normal)
        }
        else if self.isRequestedJoin {
            self.buttonGo.hidden = true
        }
        else {
            if self.currentActivity!.isAcceptedActivity() {
                self.buttonGo.hidden = true
            }
            else {
                self.buttonGo.setTitle("ACCEPT THIS INVITATION", forState: .Normal)
            }
        }
        self.mapView.userInteractionEnabled = false

        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        let coordinate = place.coordinate
        let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17)
        self.mapView.camera = camera
        self.mapView.delegate = self
        
        if self.marker != nil {
            self.marker.map = nil
        }
        self.marker = GMSMarker(position: coordinate)
        self.marker.map = self.mapView
        
        self.constraintIconWidth.constant = 0
        if let iconURLString = self.place.iconURL {
            self.iconView.imageURL = NSURL(string: iconURLString)
            // for now no icon - should be something more business specific
        }
        
        if place.photo != nil {
            self.imageView.image = place.photo
            self.constraintImageHeight.constant = 200
            self.imageView.superview?.setNeedsLayout()
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.imageView.superview?.layoutIfNeeded()
            })
        }
        else {
            // hack: if place exists, fetch the image from the photo reference
            // if place is nil and only a merchant exists, we fetch the details then use the photo reference to fetch the photos. we don't update any other aspect of the FVPlace
            self.imageView.image = nil
            self.activityIndicator.startAnimating()
            self.place!.fetchImage({ (image) -> Void in
                if (image != nil) {
                    self.imageView.image = image
                    self.constraintImageHeight.constant = 200
                    self.imageView.superview?.setNeedsLayout()
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.imageView.superview?.layoutIfNeeded()
                    })
                }
                else {
                    self.constraintImageHeight.constant = 0
                    self.imageView.superview?.setNeedsLayout()
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.imageView.superview?.layoutIfNeeded()
                    })
                }
                self.activityIndicator.stopAnimating()
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
            if self.isRequestingJoin {
                self.goToJoinActivity()
            }
            else {
                self.goToAcceptInvitation()
            }
        }
        else if button == self.buttonNext {
            /* NOT USED
            print("Next")
            if self.currentPage < self.recommendations!.count - 1 {
                self.currentPage = self.currentPage + 1
            }
            else {
                self.currentPage = 0
            }
            self.place = self.recommendations![self.currentPage]
            self.refresh()
            */
        }
    }
    
    func goToJoinActivity() {
        self.activityIndicator.startAnimating()
        HUD.show(.SystemActivity)
        ActivityRequest.joinActivity(self.currentActivity!, suggestedPlace: self.place, completion: { (results, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            if error != nil {
                HUD.flash(.Label("There was an error joining the activity."), withDelay: 2)
            }
            else {
                self.refresh()
                HUD.show(.Label("Invitation sent."))
                HUD.hide(animated: true, completion: { (complete) -> Void in
                    if self.delegate != nil {
                        self.delegate!.didSendInvitationForPlace()
                    }
                    else {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                })
            }
        })
    }

    func goToAcceptInvitation() {
        HUD.show(.SystemActivity)
        ActivityRequest.respondToJoin(self.currentActivity!, responseType: "accepted") { (results, error) -> Void in
            if error != nil {
                HUD.flash(.Label("Could not accept invitation. Please try again."), withDelay: 2)
            }
            else {
                self.refresh()
                HUD.show(.Label("Invitation accepted."))
                HUD.hide(animated: true, completion: { (complete) -> Void in
                    self.refresh()
                    if self.delegate != nil {
                        self.delegate!.didAcceptInvitationForPlace()
                    }
                    else {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                })
            }
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
