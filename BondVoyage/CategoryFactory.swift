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
    case HealthRelaxation
    case SportsRecreation
    case MusicArts
    case CultureSightseeing
    case RetailShopping
    case Beaches
    case Nightlife
    case OutdoorExtremeSports
    case Other
}

enum SUBCATEGORY: String {
    case Anything
    case Seafood, Steakhouse, Pizza, AsianFood, ItalianFood, MediterraneanFood, AmericanFood, MexicanFood, DessertSweets
    case Beer, Wine, Coffee, Tea, Cocktails
    case Movies, Bowling, LaserTag, Paintball, Gokarting, Minigolf, AmusementParks, WaterParks, Arcade, PoolHall, PokerCardGames, Chess, Checkers, Backgammon
    case Yoga, Pilates, Zumba, Kickboxing, Bootcamp, Crossfit, Barre, Spinning, PoleDancing, PersonalTraining, GroupClasses
    case Spa, Nails, BeautySalon
    case GoToAGame, WatchAGame, PickupGame, Basketball, Soccer, Football, Baseball, Softball, Volleyball, Hockey, Lacrosse, Skiing, Tennis
    case Concerts, Theatre, LiveMusic, JamSession, ArtGallery
    case Landmarks, Museums, Tours, LocalActivities
    case Malls, Boutiques, DesignerLuxuryBrands, DiscountStores, BigNameRetail
    case PopularBeaches, PartyBeaches, QuietBeaches, NudeBeaches, LocalBeaches
    case Dancing, Bars, Clubs, Lounges, StripClub
    case SailingBoating, Cycling, Hiking, MountainClimbing, Golf, ZipLine, Kayaking, WhiteWaterRafting, Surfing, SkyDiving, Tubing
    case Other
}

// THESE ARE THE ONLY CATEGORIES USED
var CATEGORIES: [CATEGORY] = [
    .Food,
    .Nightlife,
    .CultureSightseeing,
    .Fitness
]

var SUBCATEGORIES: [CATEGORY: [SUBCATEGORY]] = [
    .Food:[.Seafood, .Steakhouse, .Pizza, .AsianFood, .ItalianFood, .MediterraneanFood, .AmericanFood, .MexicanFood, .DessertSweets],
    .Drink:[.Beer, .Wine, .Coffee, .Tea, .Cocktails],
    .Entertainment:[.Movies, .Bowling, .LaserTag, .Paintball, .Gokarting, .Minigolf, .AmusementParks, .WaterParks, .Arcade, .PoolHall, .PokerCardGames, .Chess, .Checkers, .Backgammon],
    .Fitness:[.Yoga, .Pilates, .Zumba, .Kickboxing, .Bootcamp, .Crossfit, .Barre, .Spinning, .PoleDancing, .PersonalTraining, .GroupClasses],
    .HealthRelaxation: [.Spa, .Nails, .BeautySalon],
    .SportsRecreation:[.GoToAGame, .WatchAGame, .PickupGame, .Basketball, .Soccer, .Football, .Baseball, .Softball, .Volleyball, .Hockey, .Lacrosse, .Skiing, .Tennis],
    .MusicArts:[.Concerts, .Theatre, .LiveMusic, .JamSession, .ArtGallery],
    .CultureSightseeing:[.Landmarks, .Museums, .Tours, .LocalActivities],
    .RetailShopping:[.Malls, .Boutiques, .DesignerLuxuryBrands, .DiscountStores, .BigNameRetail],
    .Beaches:[.PopularBeaches, .PartyBeaches, .QuietBeaches, .NudeBeaches, .LocalBeaches],
    .Nightlife:[.Dancing, .Bars, .Clubs, .Lounges, .StripClub],
    .OutdoorExtremeSports:[.SailingBoating, .Cycling, .Hiking, .MountainClimbing, .Golf, .ZipLine, .Kayaking, .WhiteWaterRafting, .Surfing, .SkyDiving, .Tubing],
    .Other:[.Other]
]

var BG_CATEGORIES: [CATEGORY: String] = [
    .Food: "category_food",
    .Nightlife: "category-nightlife",
    .CultureSightseeing: "category-culture",
    .Fitness: "category-fitness2",

    .Drink: "event_starbucks",
    .Entertainment: "category_entertainment",
    .HealthRelaxation: "category_community",
    .SportsRecreation: "category_sports",
    .MusicArts: "category_music",
    .RetailShopping: "category_technology",
    .Beaches: "category_outdoors",
    .OutdoorExtremeSports: "category_outdoors",
    .Other: "event_karaoke"
]

class CategoryFactory: NSObject {

    // MARK: - string to CATEGORY/SUBCATEGORY enum types
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
    
    // MARK: background images
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
    
    // MARK: category titles
    class func categoryReadableString(category: CATEGORY) -> String {
        switch category {
        case .Food: return "Food & Casual Drink"
        case .Nightlife: return "Nightlife & Entertainment"
        case .CultureSightseeing: return "Culture & Sightseeing"
        case .Fitness: return "Fitness, Sport & Recreation"
            
            /*
        case .HealthRelaxation: return "Health and Relaxation"
        case .SportsRecreation: return "Sports and Recreation"
        case .MusicArts: return "Music and the Arts"
        case .RetailShopping: return "Retail Therapy and Shopping"
        case .OutdoorExtremeSports: return "Outdoor Activities, Extreme Sports"
            */
        default:
            return category.rawValue
        }
    }
    
    class func subcategoryReadableString(subcategory: SUBCATEGORY) -> String {
        switch subcategory {
        case .AsianFood: return "Asian Food"
        case .ItalianFood: return "Italian Food"
        case .MediterraneanFood: return "Mediterranean Food"
        case .AmericanFood: return "American Food"
        case .MexicanFood: return "Mexican Food"
        case .DessertSweets: return "Dessert and Sweets"
        case .LaserTag: return "Laser Tag"
        case .Gokarting: return "Go Karting"
        case .AmusementParks: return "Amusement Parks"
        case .WaterParks: return "Water Parks"
        case .Arcade: return "Games and Arcades"
        case .PoolHall: return "Pool halls"
        case .PokerCardGames: return "Poker and card games"
        case .PoleDancing: return "Pole Dancing"
        case .PersonalTraining: return "Personal Training"
        case .GroupClasses: return "Group Classes"
        case .BeautySalon: return "Beauty Salon"
        case .GoToAGame: return "Go to a Game"
        case .WatchAGame: return "Watch a Game"
        case .PickupGame: return "Join a Pickup Game"
        case .LiveMusic: return "Live Music Acts"
        case .JamSession: return "Join a Jam Session"
        case .ArtGallery: return "Art Gallery"
        case .Landmarks: return "Famous Sites and Landmarks"
        case .LocalActivities: return "Local life and activities"
        case .DesignerLuxuryBrands: return "Designer, Luxury and Name Brands"
        case .DiscountStores: return "Discount Stores"
        case .BigNameRetail: return "Big Name Retailers"
        case .StripClub: return "Gentlemen's Clubs"
        case .PopularBeaches: return "Popular Beaches"
        case .QuietBeaches: return "Quiet Beaches"
        case .PartyBeaches: return "Party Beaches"
        case .NudeBeaches: return "Nude Beaches"
        case .LocalBeaches: return "Local Beaches"
        case .SailingBoating: return "Sailing and Boating"
        case .MountainClimbing: return "Mountain Climbing"
        case .ZipLine: return "Zip Lining"
        case .WhiteWaterRafting: return "White Water Rafting"
        case .SkyDiving: return "Sky Diving"
        default: return subcategory.rawValue
        }
    }
    
    // MARK: custom search terms
    class func searchTerms(string: String) -> String? {
        let category = self.categoryForString(string)
        let subcategory = self.subcategoryForString(string)
        
        if category != nil {
            switch category! {
            case .OutdoorExtremeSports:
                return "extreme sports"
            case .RetailShopping:
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
            case .JamSession:
                return "music"
            case .LocalActivities:
                return "events"
            case .Landmarks:
                return "landmarks"
            case .DesignerLuxuryBrands:
                return "designer shopping"
            case .BigNameRetail:
                return "retail"
            case .GroupClasses:
                return "group fitness"
            default:
                return subcategory!.rawValue
            }
        }
        return nil
    }
}
