//
//  ActivityDetailViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/24/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView
import Parse
import GoogleMaps

class ActivityDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InvitationDelegate, GMSMapViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    var street: String?
    var city: String?
    
    @IBOutlet weak var mapView: GMSMapView!
    var marker: GMSMarker?
    @IBOutlet weak var constraintMapHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintTableHeight: NSLayoutConstraint!

    var activity: PFObject!
    var isRequestingJoin: Bool = false

    var allUserIds: [String] = []
    var users: [String: PFUser] = [:]
    var places: [String: BVPlace] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = self.activity.defaultImage()
        self.labelTitle.text = self.activity.shortTitle()
        
        let geopoint: PFGeoPoint = self.activity.objectForKey("geopoint") as! PFGeoPoint
        self.reverseGeocode(CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude))
        
        if self.isRequestingJoin {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .Plain, target: self, action: "goToSelectPlace")
        }
        self.mapView.userInteractionEnabled = true
        self.mapView.delegate = self
        
        self.reloadSuggestedPlaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.tableView.reloadData()
        self.constraintTableHeight.constant = CGFloat(80 * self.tableView.numberOfRowsInSection(0))
        
        if self.activity.lat() == nil && self.activity.lon() == nil {
            self.constraintMapHeight.constant = 0
        }
        else {
            var coordinate = CLLocationCoordinate2D(latitude: self.activity.lat()!, longitude: self.activity.lon()!)
            if self.places.count > 0 {
                let place: BVPlace = self.places.values.first!
                coordinate = place.coordinate
            }
            let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17)
            self.mapView.camera = camera
            
            if self.marker != nil {
                self.marker!.map = nil
            }
            self.marker = GMSMarker(position: coordinate)
            self.marker!.map = self.mapView
        }
        
        if self.street != nil {
            self.labelTitle.text = "\(self.activity.shortTitle())\nnear \(self.street!)"
        }
        else if self.city != nil {
            self.labelTitle.text = "\(self.activity.shortTitle())\nnear \(self.city!)"
        }
        else {
            self.labelTitle.text = self.activity.shortTitle()
        }
    }
    
    func reloadSuggestedPlaces() {
        self.allUserIds.removeAll()
        self.users.removeAll()
        self.places.removeAll()

        if let dict: [String: String] = self.activity.suggestedPlaces() {
            if dict.count == 0 {
                self.refresh()
            }
            for (userId, placeId) in dict {
                // load user
                let query: PFQuery = PFUser.query()!
                query.whereKey("objectId", equalTo: userId)
                query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                    if results != nil && results!.count > 0 {
                        let user: PFUser = results![0] as! PFUser
                        self.users[userId] = user
                        if self.allUserIds.contains(userId) == false {
                            self.allUserIds.append(userId)
                        }
                        self.refresh()
                    }
                }
                
                // load place
                GoogleDataProvider.placeWithId(placeId, completion: { (place, error) -> Void in
                    if place != nil {
                        self.places[userId] = BVPlace(gPlace:place!)
                        if self.allUserIds.contains(userId) == false {
                            self.allUserIds.append(userId)
                        }
                        self.refresh()
                    }
                })
            }
        }
    }
    
    func goToSelectPlace() {
        let controller: SuggestedPlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("SuggestedPlacesViewController") as! SuggestedPlacesViewController
        controller.currentActivity = self.activity
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allUserIds.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JoinCell")! as! UITableViewCell
        let userId: String = self.allUserIds[indexPath.row]
        
        let user: PFUser? = self.users[userId]
        let place: BVPlace? = self.places[userId]

        let imageView: AsyncImageView = cell.viewWithTag(1) as! AsyncImageView
        let labelName: UILabel = cell.viewWithTag(2) as! UILabel
        let labelPlace: UILabel = cell.viewWithTag(3) as! UILabel
        
        var name: String?
        if user != nil {
            name = user!.valueForKey("firstName") as? String
            if name == nil {
                name = user!.valueForKey("lastName") as? String
            }
            if name == nil {
                name = user!.username
            }
            
            if name != nil {
                labelName.text = "\(name!) wants to meet up"
                if self.activity.isAcceptedActivity() {
                    if self.activity.isOwnActivity() {
                        labelName.text = "You are meeting \(name!)"
                    }
                    else {
                        if user!.objectId! == PFUser.currentUser()?.objectId! {
                            labelName.text = "Your invitation was accepted"
                        }
                    }
                }
                else {
                    if user!.objectId! == PFUser.currentUser()?.objectId! {
                        labelName.text = "Your have sent an invitation"
                    }
                }
            }
            
            if let url: String = user?.objectForKey("photoUrl") as? String {
                imageView.imageURL = NSURL(string: url)
            }
            
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.contentMode = .ScaleAspectFill
        }
        
        if place?.name != nil {
            labelPlace.text = "at \(place!.name!)"
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // place
        let row = indexPath.row
        let userId = self.allUserIds[row]
        if let place: BVPlace = self.places[userId] {
            let controller: PlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("PlacesViewController") as! PlacesViewController
            controller.place = place
            controller.isRequestingJoin = self.isRequestingJoin
            controller.isRequestedJoin = self.activity.isJoiningActivity()
            controller.currentActivity = self.activity
            controller.joiningUserId = userId
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    @IBAction func didClickUserButton(sender: UIButton) {
        // user button
        if self.users.count > 0 {
            let user: PFUser = self.users.values.first!
            let controller: UserDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
            controller.selectedUser = user
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - InvitationDelegate
    func didSendInvitationForPlace() {
        self.navigationController?.popToViewController(self, animated: true)
        self.activity.fetchInBackgroundWithBlock { (result, error) -> Void in
            self.reloadSuggestedPlaces()
        }
        
        // also send a notification for other views not in this chain
        NSNotificationCenter.defaultCenter().postNotificationName("activity:updated", object: nil)
    }
    
    func didAcceptInvitationForPlace() {
        self.didSendInvitationForPlace()
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
                            if let lines = dict["FormattedAddressLines"] {
                                print("lines: \(lines)")
                                if lines.count > 0 {
                                    //string = lines[0] as? String
                                }
                                self.refresh()
                            }
                            if let street = dict["Street"] as? String {
                                self.street = street
                                self.refresh()
                            }
                            else if let locality = dict["SubLocality"] as? String {
                                self.city = locality
                                self.refresh()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - MapViewDelegate
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.goToMap()
    }
    
    func goToMap() {
        let controller: MapViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        if self.places.count > 0 {
            let place: BVPlace = self.places.values.first!
            controller.place = place
        }
        controller.currentActivity = self.activity
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // }
}
