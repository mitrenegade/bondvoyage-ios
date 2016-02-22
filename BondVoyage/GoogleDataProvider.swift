//
//  GoogleDataProvider.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import GoogleMaps

var photoCache = [String:UIImage]()
var detailsCache = [String:NSDictionary]()

public class PredictedPlace: NSObject {
    public let google_place_id: String
    public let desc: String

    override public var description: String {
        get { return desc }
    }

    public init(google_place_id: String, description: String) {
        self.google_place_id = google_place_id
        self.desc = description
    }
}

class GoogleDataProvider {

    var placesTask: NSURLSessionDataTask?// = NSURLSessionDataTask()
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }

    class func fetchPlaceById(placeId: String, callback: (GMSPlace?, NSError?) -> Void) {
        let client: GMSPlacesClient = GMSPlacesClient.sharedClient()
        client.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
            print("place: \(place), error: \(error)")
            if place != nil && place!.placeID == nil {
                let fvError: NSError = NSError(domain: "com.fwdvu.app.error", code: 0, userInfo: ["error": "Google Places returned invalid place"]);
                callback(nil, fvError);
            }
            else {
                callback(place, error)
            }
        })
    }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String]?, searchTerms: String?, completion: (([BVPlace], NSString?) -> Void)) -> ()
    {
        // sort by prominence requires radius; sort by distance cannot have radius
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(GOOGLE_API_SERVER_KEY)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        //    var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&rankby=distance&sensor=true"
//        let typesString = types.count > 0 ? types.joinWithSeparator("|") : "food"
//        urlString += "&types=\(typesString)"
        if searchTerms != nil {
            urlString += "&name=\(searchTerms!)"
        }
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        if placesTask != nil && placesTask!.taskIdentifier > 0 && placesTask!.state == .Running {
            placesTask!.cancel()
            placesTask = nil
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            var placesArray = Array() as [BVPlace]
            if data == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(placesArray, nil)
                }
                return
            }
            if let json = (try? NSJSONSerialization.JSONObjectWithData(data!, options:[])) as? NSDictionary {
                //        println(json["error_message"]!)
                if let results = json["error_message"] as? NSString {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(placesArray, results)
                    }
                }
                else if let results = json["results"] as? NSArray {
                    for rawPlace:AnyObject in results {
                        let place = BVPlace(dictionary: rawPlace as! NSDictionary, acceptedTypes: types) as BVPlace
                        placesArray.append(place)
                        /*
                        if let reference = place.photoReference {
                            self.fetchPhotoFromReference(reference) { image in
                                place.photo = image
                            }
                        }
                        */
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(placesArray, nil)
            }
        }
        placesTask!.resume()
    }


    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((String?) -> Void)) -> ()
    {
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?key=\(GOOGLE_API_SERVER_KEY)&origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=walking"

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var encodedRoute: String?
            if let json = (try? NSJSONSerialization.JSONObjectWithData(data!, options:[])) as? [String:AnyObject] {

                print(json["error_message"]!)

                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
                    if let route = routes.first as? [String : AnyObject] {
                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                            if let points = polyline["points"] as AnyObject? as? String {
                                encodedRoute = points
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(encodedRoute)
            }
            }.resume()
    }

    func fetchAutocompleteWithSearch(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], searchTerms: String!, completion: (([PredictedPlace], NSString?) -> Void)) -> () {
        let params = "input=\(searchTerms!)&types=establishment|geocode&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&language=en"
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?\(params)&key=\(GOOGLE_API_SERVER_KEY)"
        let encoded = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let URL = NSURL(string:encoded)
        session.dataTaskWithURL(URL!) {data, response, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    completion([], nil)
                }
            }
            else {
                var placesArray = [PredictedPlace]()
                if let json = (try? NSJSONSerialization.JSONObjectWithData(data!, options:[])) as? NSDictionary {
                    if let predictions = json["predictions"] as? Array<AnyObject> {
                        placesArray = predictions.map { (prediction: AnyObject) -> PredictedPlace in
                            return PredictedPlace(
                                google_place_id: prediction["place_id"] as! String,
                                description: prediction["description"] as! String
                            )
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completion(placesArray, nil)
                }
            }
        }.resume()
    }

    class func fetchPhotoFromReference(reference: String, completion: ((UIImage?) -> Void)) -> ()
    {
        if let photo = photoCache[reference] as UIImage! {
            completion(photo)
        } else {
            let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=\(reference)&key=\(GOOGLE_API_SERVER_KEY)"
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            NSURLSession.sharedSession().downloadTaskWithURL(NSURL(string: urlString)!) {url, response, error in
                let exists = url as NSURL?
                if exists == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil)
                    }
                    return
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let downloadedPhoto = UIImage(data: NSData(contentsOfURL: url!)!)
                photoCache[reference] = downloadedPhoto
                dispatch_async(dispatch_get_main_queue()) {
                    completion(downloadedPhoto)
                }
                }.resume()
        }
    }

    class func fetchDetailsFromPlaceId(placeid: String, completion: ((NSDictionary?) -> Void)) -> ()
    {
        //https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4&key;=AddYourOwnKeyHere

        if let details = detailsCache[placeid] as NSDictionary! {
            completion(details)
        } else {
            let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid)&key=\(GOOGLE_API_SERVER_KEY)"

            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            NSURLSession.sharedSession().downloadTaskWithURL(NSURL(string: urlString)!) {url, response, error in
                let exists = url as NSURL?
                if exists == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(nil)
                    }
                    return
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let data = NSData(contentsOfURL: url!)!
                let dictionary:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options:[])) as! NSDictionary
                detailsCache[placeid] = dictionary
                dispatch_async(dispatch_get_main_queue()) {
                    completion(dictionary)
                }
                }.resume()
        }
    }

}
