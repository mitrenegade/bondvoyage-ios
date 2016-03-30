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

class ActivityDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InvitationDelegate, GMSMapViewDelegate, UITextViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    var street: String?
    var city: String?
    
    var recommendedVenueNames: [String]!
    var recommendedVenueStreets: [String]!
    var recommendedVenueCityState: [String]!
    /*
    @IBOutlet weak var mapView: GMSMapView!
    var marker: GMSMarker?
    @IBOutlet weak var constraintMapHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintTableHeight: NSLayoutConstraint!

    @IBOutlet weak var buttonInvite: UIButton!
    @IBOutlet weak var constraintButtonHeight: NSLayoutConstraint!
    */
    
    @IBOutlet weak var textView: UITextView!
    
    var activity: PFObject!
    var isRequestingJoin: Bool = false

    var allUserIds: [String] = []
    var users: [String: PFUser] = [:]
    var places: [String: BVPlace] = [:]
    
    @IBOutlet weak var profileView: AsyncImageView!
    @IBOutlet weak var constraintProfileWidth: NSLayoutConstraint!
    @IBOutlet weak var profileButton: UIButton!
    
    weak var browser: ActivityBrowserViewController?
    
    var matchedUser: PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = self.activity.defaultImage()
        self.labelTitle.text = ""
        
        let geopoint: PFGeoPoint = self.activity.objectForKey("geopoint") as! PFGeoPoint
        // TODO: enable this when we use actual phone locations again
        //self.reverseGeocode(CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude))
        
        // hide map. TODO: Enable map if user locations are used
        /*
        self.mapView.userInteractionEnabled = false
        self.mapView.delegate = self
        self.constraintMapHeight.constant = 0
        
        if !self.isRequestingJoin {
            self.constraintButtonHeight.constant = 0
            self.buttonInvite.hidden = true
        }
        */
        self.refreshTitle()
        self.refreshPlaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        /*
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
        self.refreshPlaces()
        self.refreshTitle()
        */
    }
    
    func refreshTitle() {
        // activity's user
        if self.activity.isOwnActivity() {
            if let userIds: [String] = self.activity!.objectForKey("joining") as? [String] {
                let userId = userIds[0]
                let query: PFQuery = PFUser.query()!
                query.whereKey("objectId", equalTo: userId)
                query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                    if results != nil && results!.count > 0 {
                        let user: PFUser = results![0] as! PFUser
                        self.matchedUser = user
                        
                        if let name: String = user.objectForKey("firstName") as? String {
                            let categoryString = CategoryFactory.categoryReadableString(self.activity!.category()!)
                            if self.activity!.isAcceptedActivity() {
                                if self.activity!.category() != nil {
                                    self.labelTitle.text = "\(categoryString) with \(name)"
                                }
                                else {
                                    self.labelTitle.text = "Matched with \(name)"
                                }
                            }
                            else {
                                var categoryTitle: String = ""
                                if self.activity!.category() != nil {
                                    categoryTitle = " over \(categoryString)"
                                }
                                self.labelTitle.text = "\(name) matched with you\(categoryTitle)"
                            }
                        }
                        
                        if let photoURL: String = user.valueForKey("photoUrl") as? String {
                            self.profileView.imageURL = NSURL(string: photoURL)
                        }
                        else {
                            self.profileView.image = UIImage(named: "profile-icon")
                        }
                    }
                    
                    self.refreshPlaces()
                }
            }
        }
        else {
            if let user: PFUser = self.activity.user() {
                user.fetchIfNeededInBackgroundWithBlock({ (result, error) -> Void in
                    self.matchedUser = user
                    if result != nil {
                        self.labelTitle.text = self.activity.shortTitle()
                        
                        if let photoURL: String = result!.valueForKey("photoUrl") as? String {
                            self.profileView.imageURL = NSURL(string: photoURL)
                        }
                        else {
                            self.profileView.image = UIImage(named: "profile-icon")
                        }
                    }
                    
                    self.refreshPlaces()
                })
            }
        }
    }
    
    func refreshPlaces() {
        var string: String = "Congratulations on your successful bond"
        if self.matchedUser != nil && self.matchedUser!.objectForKey("firstName") != nil {
            let name = self.matchedUser!.objectForKey("firstName")!
            string = "\(string) with \(name)"
        }
        
        if self.activity.category() != nil {
            let category = CategoryFactory.categoryReadableString(self.activity.category()!)
            string = "\(string) for \(category)."
        }
        else {
            string = "\(string)."
        }
        
        string = "\(string)\n\nWe recommend the following venues: \n\n"
        
        self.recommendedVenueNames = ["Cactus Club", "Meadhall", "The Elephant and Bell"]
        self.recommendedVenueStreets = ["939 Boylston St", "4 Cambridge Center", "45 Union St"]
        self.recommendedVenueCityState = ["Boston, MA 02215", "Cambridge, MA 02142", "Boston, MA 02108"]
        for var i=0; i<self.recommendedVenueNames.count; i++ {
            string = "\(string)\(self.recommendedVenueNames[i])\n\(self.recommendedVenueStreets[i])\n\(self.recommendedVenueCityState[i])\n\n"
        }
        
        let attrs = [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 14.0)!]
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: attrs)
        
        for var i=0; i<self.recommendedVenueNames.count; i++ {
            let name = self.recommendedVenueNames[i]
            var range = (attributedString.string as NSString).rangeOfString(self.recommendedVenueNames[i])
            attributedString.addAttribute(NSLinkAttributeName, value: "bondvoyage://\(name)", range: range)
            range = (attributedString.string as NSString).rangeOfString(self.recommendedVenueStreets[i])
            attributedString.addAttribute(NSLinkAttributeName, value: "bondvoyage://\(name)", range: range)
            range = (attributedString.string as NSString).rangeOfString(self.recommendedVenueCityState[i])
            attributedString.addAttribute(NSLinkAttributeName, value: "bondvoyage://\(name)", range: range)
        }
        
        self.textView.attributedText = attributedString
        self.textView.contentOffset = CGPointMake(0, 0)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        for var i=0; i<self.recommendedVenueNames.count; i++ {
            let name = self.recommendedVenueNames[i]
            if URL.absoluteString == name {
                print("name \(name)")
            }
            
            let address = "\(self.recommendedVenueNames[i]) \(self.recommendedVenueStreets[i]) \(self.recommendedVenueCityState[i])"
            self.openInMaps(address)
            
            // open a different url
            return false
        }
        return false
    }
    
    func openInMaps(address: String) {
        let escapedString = address.stringByReplacingOccurrencesOfString(" ", withString: "+")
        print("original \(address) escaped \(escapedString)")
        let url: NSURL? = NSURL(string: "comgooglemaps://?q=\(escapedString)")
        if url != nil && UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            var message = "BondVoyage could not open the map app for this address"
            if address.characters.count > 0 {
                message = "\(message): \(address)"
            }
            self.simpleAlert("Could not open Google Maps", message: message)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("JoinCell")! as UITableViewCell
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
        // owner's profile
        if sender == self.profileButton {
            print("profile")
            if let user: PFUser = self.activity.user() {
                let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
                controller.selectedUser = user
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
            /*
            // invite
        else if sender == self.buttonInvite {
            self.goToSelectPlace()
        }
        */
            /*
        else {
            // user button
            let cell: UITableViewCell = sender.superview!.superview! as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)!
            if indexPath.row < self.users.count {
                let userId = self.allUserIds[indexPath.row]
                let user: PFUser = self.users[userId]!
                let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
                controller.selectedUser = user
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        */
    }
    
    // MARK: - InvitationDelegate
    func didSendInvitationForPlace() {
        /*
        self.constraintButtonHeight.constant = 0 // why does this not hide the button?
        self.buttonInvite.hidden = true

        if self.browser != nil {
            self.browser!.didSendInvitationForPlace()
        }
        else {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        self.activity.fetchInBackgroundWithBlock { (result, error) -> Void in
            self.reloadSuggestedPlaces()
        }
        
        // also send a notification for other views not in this chain
        NSNotificationCenter.defaultCenter().postNotificationName("activity:updated", object: nil)
        */
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
}
