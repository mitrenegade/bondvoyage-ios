//
//  CategoryFactory.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/30/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

enum CATEGORY: String {
    case Arts = "Arts and Culture"
    case Business, Community, Education, Entertainment
    case Food = "Food and Drink"
    case Health = "Health and Fitness"
    case Music
    case Outdoors = "Outdoors and Adventure"
    case Sports = "Sports and Recreation"
    case Technology, Other
}

enum SUBCATEGORY: String {
    // arts
    case Museums
    case Gallery = "Art gallery"
    // business
    case Networking
    // community
    case Volunteering
    // education
    case Tutoring
    // entertainment
    case Movies
    case Theatre
    case Bowling
    // food
    case Brunch
    case Dinner
    case Drinks
    case BBQ
    // health
    case Yoga
    case Workout
    case Jogging
    case Gym
    // music
    case Dancing
    case Concert
    case Jam = "Jam session"
    case Live = "Live music"
    case Opera
    // outdoors
    case Hiking
    case Volleyball
    case Beach
    // sports
    case Pickup = "Pickup sports"
    case WatchGame = "Watch the game"
    case SportsMatch = "Go to a match"
    // Technology
    case VideoGames = "Play video games"
    case LaserTag = "Laser tag"
}

var CATEGORIES: [CATEGORY] = [.Arts, .Business, .Community, .Education, .Entertainment, .Food, .Health, .Music, .Outdoors, .Sports, .Technology]
var SUBCATEGORIES: [CATEGORY: [SUBCATEGORY]] = [
    .Arts: [.Museums, .Gallery],
    .Business: [.Networking],
    .Community: [.Volunteering],
    .Education: [.Tutoring],
    .Entertainment: [.Movies, .Theatre, .Bowling],
    .Food: [.Brunch, .Dinner, .Drinks, .BBQ],
    .Health: [.Yoga, .Workout, .Jogging, .Gym],
    .Music: [.Concert, .Jam, .Live, .Opera],
    .Outdoors: [.Hiking, .Volleyball, .Beach],
    .Sports: [.Pickup, .WatchGame, .SportsMatch],
    .Technology: [.VideoGames, .LaserTag]
]

var BG_CATEGORIES: [CATEGORY: String] = [
    .Arts: "category_art",
    .Business: "category_business",
    .Community: "category_community",
    .Education: "category_education",
    .Entertainment: "category_entertainment",
    .Food: "category_food",
    .Health: "category_health",
    .Music: "category_music",
    .Outdoors: "category_outdoors",
    .Sports: "category_sports",
    .Technology: "category_technology"
]
class CategoryFactory: NSObject {

    class func categories() -> [String] {
        return CATEGORIES.map({ (category) -> String in
            return category.rawValue
        })
    }
    
    class func subCategories(category: String) -> [String] {
        for cat: CATEGORY in CATEGORIES {
            if cat.rawValue == category {
                let sub: [SUBCATEGORY] = SUBCATEGORIES[cat]!
                return sub.map({ (subcategory) -> String in
                    return subcategory.rawValue
                })
            }
        }
        return []
    }
    
    class func categoryBgImage(category: String) -> UIImage {
        for cat: CATEGORY in CATEGORIES {
            if cat.rawValue == category {
                let name = BG_CATEGORIES[cat]!
                return UIImage(named:"\(name).jpg")!
            }
        }
        return UIImage(named: "event_starbucks.jpg")!
    }

    class func subcategoryBgImage(subcategory: String) -> UIImage {
        for cat: CATEGORY in CATEGORIES {
            let sub: [SUBCATEGORY] = SUBCATEGORIES[cat]!
            let subcategories: [String] = sub.map({ (subcategory) -> String in
                return subcategory.rawValue
            })
            if subcategories.contains(subcategory) {
                return self.categoryBgImage(cat.rawValue)
            }
        }
        return UIImage(named: "event_starbucks.jpg")!
    }
}
