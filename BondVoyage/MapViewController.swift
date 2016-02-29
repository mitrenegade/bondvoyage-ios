//
//  MapViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/29/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    var place: BVPlace?
    var marker: GMSMarker!
    var currentActivity: PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.userInteractionEnabled = true
        self.mapView.myLocationEnabled = true
        
        self.refresh()
    }
    
    func refresh() {
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: PHILADELPHIA_LAT, longitude: PHILADELPHIA_LON)
        if self.place != nil {
            coordinate = place!.coordinate
            let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17)
            self.mapView.camera = camera
        }
        else if self.currentActivity != nil {
            let geopoint = self.currentActivity!.objectForKey("geopoint") as! PFGeoPoint
            coordinate = CLLocationCoordinate2D(latitude: geopoint.latitude, longitude: geopoint.longitude)
            let camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 17)
            self.mapView.camera = camera
        }
        self.mapView.delegate = self
        
        if self.marker != nil {
            self.marker.map = nil
        }
        self.marker = GMSMarker(position: coordinate)
        self.marker.map = self.mapView
        
    }
}
