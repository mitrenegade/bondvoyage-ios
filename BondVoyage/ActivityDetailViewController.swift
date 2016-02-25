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

class ActivityDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    
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
        
        if self.isRequestingJoin {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .Plain, target: self, action: "goToSelectPlace")
        }
        self.mapView.userInteractionEnabled = false
        
        self.reloadSuggestedPlaces()
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.constraintTableHeight.constant = CGFloat(80 * self.tableView.numberOfRowsInSection(0))
        self.tableView.reloadData()
        
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
    }
    
    func reloadSuggestedPlaces() {
        let dictArray: [[String: String]] = self.activity.suggestedPlaces()
        for dict: [String: String] in dictArray {
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
        if self.places.count > 0 {
            let place: BVPlace = self.places.values.first!
            let controller: PlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("PlacesViewController") as! PlacesViewController
            controller.place = place
            controller.isRequestingJoin = self.isRequestingJoin
            controller.isRequestedJoin = self.activity.isJoiningActivity()
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
}
