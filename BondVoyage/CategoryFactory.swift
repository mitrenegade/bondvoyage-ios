//
//  CategoryFactory.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/30/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

enum CATEGORY: String {
    case Food
    case Drink
    case Entertainment
    case Fitness
    case Health = "Health and Relaxation"
    case Sports = "Sports and Recreation"
    case Music = "Music and the Arts"
    case Culture = "Culture and Sightseeing"
    case Retail = "Retail Therapy and Shopping"
    case Beaches
    case Nightlife
    case Outdoor = "Outdoor Activities, Extreme Sports"
    case Other
}

enum SUBCATEGORY: String {
    case Anything
    case Seafood, Steakhouse, Pizza, Asian, Italian, Mediterranean, American, Mexican, Dessert = "Dessert and Sweets"
    case Beer, Wine, Coffee, Tea, Cocktails
    case Movies, Bowling, LaserTag = "Laser Tag", Paintball, Gokarting = "Go Karting", Minigolf, AmusementParks = "Amusement Parks", WaterParks = "Water Parks", Arcade = "Games and Arcades", Pool = "Pool halls", Poker = "Poker and card games", Chess, Checkers, Backgammon
    case Yoga, Pilates, Zumba, Kickboxing, Bootcamp, Crossfit, Barre, Spinning, Pole = "Pole Dancing", PersonalTraining = "Personal Training", Group = "Group Classes"
    case Spa, Nails, Salon = "Beauty Salon"
    case GoToAGame = "Go to a game", WatchAGame = "Watch a game", PickupGame = "Join a pickup game", Basketball, Soccer, Football, Baseball, Softball, Volleyball, Hockey, Lacrosse, Skiing, Tennis
    case Concerts, Theatre, LiveMusic = "Live Music Acts", Jam = "Join a jam session", Art = "Art Gallery"
    case Landmarks = "Famous Sites and Landmarks", Museums, Tours, Local = "Local life and activities"
    case Malls, Boutiques, Designer = "Designer, Luxury and Name Brands", Discount = "Discount Stores", Retail = "Big Name Retailers"
    case PopularBeaches = "Popular", PartyBeaches = "Party", QuietBeaches = "Quiet", NudeBeaches = "Nude", LocalBeaches = "Local"
    case Dancing, Bars, Clubs, Lounges, StripClub = "Gentlemen's Club"
    case Sailing = "Sailing and Boating", Cycling, Hiking, Climbing = "Mountain Climbing", Golf, ZipLine = "Zip Lining", Kayaking, Rafting = "White Water Rafting", Surfing, SkyDiving = "Sky Diving", Tubing
    case Other
}

var CATEGORIES: [CATEGORY] = [
    .Food,
    .Drink,
    .Entertainment,
    .Fitness,
    .Sports,
    .Music,
    .Culture,
    .Retail,
    .Beaches,
    .Nightlife,
    .Outdoor,
    .Other
]

var SUBCATEGORIES: [CATEGORY: [SUBCATEGORY]] = [
    .Food:[.Seafood, .Steakhouse, .Pizza, .Asian, .Italian, .Mediterranean, .American, .Mexican, .Dessert],
    .Drink:[.Beer, .Wine, .Coffee, .Tea, .Cocktails],
    .Entertainment:[.Movies, .Bowling, .LaserTag, .Paintball, .Gokarting, .Minigolf, .AmusementParks, .WaterParks, .Arcade, .Pool, .Poker, .Chess, .Checkers, .Backgammon],
    .Fitness:[.Yoga, .Pilates, .Zumba, .Kickboxing, .Bootcamp, .Crossfit, .Barre, .Spinning, .Pole, .PersonalTraining, .Group],
    .Health: [.Spa, .Nails, .Salon],
    .Sports:[.GoToAGame, .WatchAGame, .PickupGame, .Basketball, .Soccer, .Football, .Baseball, .Softball, .Volleyball, .Hockey, .Lacrosse, .Skiing, .Tennis],
    .Music:[.Concerts, .Theatre, .LiveMusic, .Jam, .Art],
    .Culture:[.Landmarks, .Museums, .Tours, .Local],
    .Retail:[.Malls, .Boutiques, .Designer, .Discount, .Retail],
    .Beaches:[.PopularBeaches, .PartyBeaches, .QuietBeaches, .NudeBeaches, .LocalBeaches],
    .Nightlife:[.Dancing, .Bars, .Clubs, .Lounges, .StripClub],
    .Outdoor:[.Sailing, .Cycling, .Hiking, .Climbing, .Golf, .ZipLine, .Kayaking, .Rafting, .Surfing, .SkyDiving, .Tubing],
    .Other:[.Other]
]

var BG_CATEGORIES: [CATEGORY: String] = [
    .Food: "category_food",
    .Drink: "event_starbucks",
    .Entertainment: "category_entertainment",
    .Fitness: "category_health",
    .Sports: "category_sports",
    .Music: "category_music",
    .Culture: "event_ducktours",
    .Retail: "category_technology",
    .Beaches: "category_outdoors",
    .Nightlife: "event_salsa",
    .Outdoor: "category_outdoors",
    .Other: "event_karaoke"
]

class CategoryFactory: NSObject {

    class func categoryForString(string: String) -> CATEGORY? {
        for cat: CATEGORY in CATEGORIES {
            if cat.rawValue.lowercaseString == string.lowercaseString {
                return cat
            }
        }
        return nil
    }
    
    class func subcategoryForString(string: String) -> SUBCATEGORY? {
        for cat: CATEGORY in CATEGORIES {
            for sub: SUBCATEGORY in SUBCATEGORIES[cat]! {
                if sub.rawValue.lowercaseString == string.lowercaseString {
                    return sub
                }
            }
        }
        return nil
    }
    
    class func categoryStrings() -> [String] {
        return CATEGORIES.map({ (category) -> String in
            return category.rawValue
        })
    }
    
    class func subCategoryStrings(category: String) -> [String] {
        if let cat: CATEGORY = self.categoryForString(category) {
            let sub: [SUBCATEGORY] = SUBCATEGORIES[cat]!
            return sub.map({ (subcategory) -> String in
                return subcategory.rawValue
            })
        }
        return []
    }
    
    class func categoryBgImage(category: String) -> UIImage {
        for cat: CATEGORY in CATEGORIES {
            if cat.rawValue.lowercaseString == category.lowercaseString {
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
                return subcategory.rawValue.lowercaseString
            })
            if subcategories.contains(subcategory.lowercaseString) {
                return self.categoryBgImage(cat.rawValue.lowercaseString)
            }
        }
        return UIImage(named: "event_starbucks.jpg")!
    }
    
    class func searchTerms(string: String) -> String? {
        let category = self.categoryForString(string)
        let subcategory = self.subcategoryForString(string)
        
        if category != nil {
            switch category! {
            case .Outdoor:
                return "extreme sports"
            case .Retail:
                return "shopping"
            default:
                return category!.rawValue
            }
        }
        else if subcategory != nil {
            switch subcategory! {
            case .Other:
                return ""
            case .GoToAGame:
                return "sports"
            case .WatchAGame:
                return "sports"
            case .PickupGame:
                return "sports"
            case .Jam:
                return "music"
            case .Local:
                return "events"
            case .Landmarks:
                return "landmarks"
            case .PopularBeaches:
                return subcategory!.rawValue + " beaches"
            case .PartyBeaches:
                return subcategory!.rawValue + " beaches"
            case .QuietBeaches:
                return subcategory!.rawValue + " beaches"
            case .LocalBeaches:
                return subcategory!.rawValue + " beaches"
            case .NudeBeaches:
                return subcategory!.rawValue + " beaches"
            case .Designer:
                return "designer shopping"
            case .Retail:
                return "retail"
            case .Group:
                return "group fitness"
            default:
                return subcategory!.rawValue
            }
        }
        return nil
    }
}
