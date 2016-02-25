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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = self.activity.defaultImage()
        self.labelTitle.text = self.activity.shortTitle()
        
        if self.isRequestingJoin {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .Plain, target: self, action: "goToSelectPlace")
        }
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.constraintTableHeight.constant = CGFloat(40 * self.tableView.numberOfRowsInSection(0))
        
        if self.activity.lat() == nil && self.activity.lon() == nil {
            self.constraintMapHeight.constant = 0
        }
        else {
            let coordinate = CLLocationCoordinate2D(latitude: self.activity.lat()!, longitude: self.activity.lon()!)
            let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17)
            self.mapView.camera = camera
            
            if self.marker != nil {
                self.marker!.map = nil
            }
            self.marker = GMSMarker(position: coordinate)
            self.marker!.map = self.mapView
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
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("JoinCell")! as! ActivitiesCell
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToActivityDetail" {
            let controller: ActivityDetailViewController = segue.destinationViewController as! ActivityDetailViewController
            controller.activity = sender as! PFObject
            controller.isRequestingJoin = false
        }
    }

}
