//
//  BVPlace.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import GoogleMaps

class BVPlace : NSObject {

    // immutable
    let placeId: NSString?
    let placeType: String
    let coordinate: CLLocationCoordinate2D

    var name: String?
    var address: String?
    var photoReference: String?
    var photo: UIImage?
    var dictionary: NSDictionary?
    var distance: Double!
    var detailsDict: NSDictionary?
    var phone: NSString?
    var website: NSString?
    var shortDescription: NSString?

    var locale_code: NSString? // ISO Country code, used to localize currency

    // init from results of google places API with general search
    init(dictionary:NSDictionary, acceptedTypes: [String]?)
    {
        // these have to exist
        self.dictionary = dictionary
        placeId = dictionary["place_id"] as! String

        let location = dictionary["geometry"]?["location"] as! NSDictionary
        let lat = location["lat"] as! CLLocationDegrees
        let lng = location["lng"] as! CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)

        var foundType = "other"
        /*
        let possibleTypes = acceptedTypes?.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
        for type in dictionary["types"] as! [String] {
            if possibleTypes.contains(type) {
                foundType = type
                break
            }
        }
        */
        placeType = foundType

        super.init()
        self.addPlaceDictionary(dictionary) // add additional info from dictionary
    }

    // init from GMS API: created using a GMSPlace
    init( gPlace: GMSPlace) {
        if gPlace.name != nil {
            self.name = gPlace.name
        }
        
        self.placeId = gPlace.placeID
        self.coordinate = gPlace.coordinate
        self.phone = gPlace.phoneNumber

        var foundType = "establishment"
        if gPlace.types.count > 0 {
            for place: String in gPlace.types as! [String] {
                if let _: Int = ALL_PLACES_CATEGORIES.indexOf(place) {
                    foundType = place
                    break
                }
            }
        }
        self.placeType = foundType

        if gPlace.formattedAddress != nil {
            self.address = gPlace.formattedAddress
        }
        
        if gPlace.website != nil {
            self.website = gPlace.website.absoluteString
        }
        
        super.init()
        self.dictionary = nil
    }

    func addPlaceDictionary(dictionary:NSDictionary) {
        self.dictionary = dictionary

        name = dictionary["name"] as? String
        let addr = dictionary["formatted_address"] as? String
        if (addr != nil) {
            address = addr!
        }
        else {
            address = dictionary["vicinity"] as! String?
        }

        if let photos = dictionary["photos"] as? NSArray {
            let photo = photos.firstObject as! NSDictionary
            photoReference = photo["photo_reference"] as? String
        }
        
        if self.detailsDict == nil {
            GoogleDataProvider.fetchDetailsFromPlaceId(self.placeId as! String, completion: { (dictionary) -> Void in
                if dictionary != nil {
                    self.formatDetails(dictionary!)
                }
            })
        }
    }
    
    func contactString() -> NSAttributedString? {
        var contactString = "" as String
        /*
        if (self.address != nil) {
            contactString = "\(contactString)\(self.address!)\n"
        }
        */
        if (self.phone != nil) {
            contactString = "\(contactString)\(self.phone!) Call\n"
        }
        if (self.website != nil) {
            contactString = "\(contactString)\(self.website!)\n"
        }

        let attrs = [NSFontAttributeName : UIFont(name: "Archer-Book", size: 14.0)!]
        let linkString = NSMutableAttributedString(string: contactString, attributes: attrs) as NSMutableAttributedString

        if (self.phone != nil) {
            let linkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            let targetString = contactString as NSString
            var range = targetString.rangeOfString(self.phone as! String)
            var otherAttrs = [NSForegroundColorAttributeName: linkColor] as [String:AnyObject]
            linkString.addAttributes(otherAttrs, range: range)

            range = targetString.rangeOfString("Call")
            otherAttrs = [NSFontAttributeName : UIFont(name: "Archer-Bold", size: 14.0)!,
                NSForegroundColorAttributeName: linkColor]
            linkString.addAttributes(otherAttrs, range: range)
        }

        return linkString
    }

    func fetchContact(completion: ((NSAttributedString?) -> Void)) -> () {
        if (self.placeId == nil) {
            completion(nil)
            return
        }
        if (self.detailsDict != nil) {
            completion(self.contactString())
            return
        }
        GoogleDataProvider.fetchDetailsFromPlaceId(self.placeId as! String, completion: { (dictionary) -> Void in
            if dictionary != nil {
                self.formatDetails(dictionary!)
            }
            completion(self.contactString())
        })
    }

    func fetchImage(completion: ((UIImage?) -> Void)) -> () {
        if (self.photo != nil) {
            completion(self.photo)
            return
        }
        if self.photoReference != nil {
            GoogleDataProvider.fetchPhotoFromReference(self.photoReference!, completion: { (image) -> Void in
                self.photo = image
                completion(self.photo)
            })
            return
        }
        GoogleDataProvider.fetchDetailsFromPlaceId(self.placeId as! String, completion: { (dictionary) -> Void in
            if dictionary != nil {
                self.formatDetails(dictionary!)
            }
            if self.photoReference != nil {
                GoogleDataProvider.fetchPhotoFromReference(self.photoReference!, completion: { (image) -> Void in
                    self.photo = image
                    completion(self.photo)
                })
                return
            }
            else {
                completion(nil) 
            }
        })
    }
    
    func formatDetails(dictionary: NSDictionary) {
        let details: AnyObject? = dictionary["result"]
        if details != nil {
            //print("\(details)")
            self.detailsDict = details as? NSDictionary
            self.phone = self.detailsDict!["formatted_phone_number"] as? NSString
            self.website = self.detailsDict!["website"] as? NSString
            self.address = self.detailsDict!["formatted_address"] as! NSString as String

            // find country code
            var country : NSString?
            if let address_components = details!.objectForKey("address_components") as! NSArray! {
                for item in address_components {
                    let dict = item as! NSDictionary
                    let typesArray = dict["types"]! as! NSArray
                    if typesArray.containsObject("country") {
                        country = dict["short_name"] as! NSString?
                        break
                    }
                }
            }
            self.locale_code = country
            //print("country found for \(self.name): \(self.locale_code!)")
            
            // photo reference 
            if let photos = self.detailsDict!["photos"] as? NSArray {
                let photo = photos.firstObject as! NSDictionary
                photoReference = photo["photo_reference"] as? String
            }

        }
    }
/*
Types can be found here:
https://developers.google.com/places/documentation/supported_types

Relevant ones that will be used:
*/

let ALL_PLACES_CATEGORIES: [String] = [
    "accounting",
    "airport",
    "amusement_park",
    "aquarium",
    "art_gallery",
    "bakery",
    "bank",
    "bar",
    "beauty_salon",
    "bicycle_store",
    "book_store",
    "bowling_alley",
    "bus_station",
    "cafe",
    "campground",
    "car_dealer",
    "car_rental",
    "car_repair",
    "car_wash",
    "casino",
    "cemetery",
    "church",
    "clothing_store",
    "convenience_store",
    "dentist",
    "department_store",
    "doctor",
    "electrician",
    "electronics_store",
    "establishment",
    "finance",
    "fire_station",
    "florist",
    "food",
    "funeral_home",
    "furniture_store",
    "gas_station",
    "general_contractor",
    "grocery_or_supermarket",
    "gym",
    "hair_care",
    "hardware_store",
    "health",
    "hindu_temple",
    "home_goods_store",
    "hospital",
    "insurance_agency",
    "jewelry_store",
    "laundry",
    "lawyer",
    "library",
    "liquor_store",
    "locksmith",
    "lodging",
    "meal_delivery",
    "meal_takeaway",
    "mosque",
    "movie_rental",
    "movie_theater",
    "moving_company",
    "museum",
    "night_club",
    "painter",
    "park",
    "parking",
    "pet_store",
    "pharmacy",
    "physiotherapist",
    "place_of_worship",
    "plumber",
    "police",
    "post_office",
    "real_estate_agency",
    "restaurant",
    "roofing_contractor",
    "rv_park",
    "school",
    "shoe_store",
    "shopping_mall",
    "spa",
    "stadium",
    "storage",
    "store",
    "subway_station",
    "synagogue",
    "taxi_stand",
    "train_station",
    "travel_agency",
    "university",
    "veterinary_care",
    "zoo"
]
}