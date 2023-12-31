//
//  SuggestedPlacesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/22/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import CoreLocation
import AsyncImageView
import Parse
import PKHUD

class SuggestedPlacesViewController: UITableViewController {

    let dataProvider = GoogleDataProvider()
    
    var currentActivity: PFObject?
    var places: [BVPlace]?
    
    var delegate: InvitationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let geopoint: PFGeoPoint = self.currentActivity!.objectForKey("geopoint") as! PFGeoPoint
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
        if let categories: [String] = self.currentActivity!.objectForKey("categories") as? [String] {
            let search = CategoryFactory.searchTerms(categories[0])
            HUD.show(.SystemActivity)
            dataProvider.fetchPlacesNearCoordinate(coordinate, radius: 8000, types: nil, searchTerms:search) { (results, errorString) -> Void in
                print("results \(results)")
                if !results.isEmpty {
                    HUD.hide(animated: true, completion: nil)
                    self.places = results
                    self.tableView.reloadData()
                }
                else {
                    HUD.flash(.Label("No locations found"), delay: 2)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.places == nil {
            return  0
        }
        return self.places!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaceCell", forIndexPath: indexPath)

        let imageView: AsyncImageView = cell.viewWithTag(1) as! AsyncImageView
        let labelTitle: UILabel = cell.viewWithTag(2) as! UILabel
        
        if indexPath.row < self.places?.count {
            let place: BVPlace = self.places![indexPath.row]
            labelTitle.text = place.name
            if let urlString = place.iconURL {
                imageView.imageURL = NSURL(string: urlString)
            }
            else {
                imageView.imageURL = nil
            }
        }
        // Configure the cell...

        return cell
    }
    

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToPlace" {
            print("Here")
            let cell: UITableViewCell = sender as! UITableViewCell
            let row = self.tableView.indexPathForCell(cell)!.row
            let place: BVPlace = self.places![row]
            
            let controller: PlacesViewController = segue.destinationViewController as! PlacesViewController
            controller.place = place
            controller.recommendations = self.places
            controller.currentActivity = self.currentActivity
            controller.isRequestingJoin = true
            controller.delegate = self.delegate
        }
    }
}
