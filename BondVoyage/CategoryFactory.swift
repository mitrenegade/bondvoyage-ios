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
    case Fitness
    case CultureSightseeing
    case Nightlife
}

// THESE ARE THE ONLY CATEGORIES USED
var CATEGORIES: [CATEGORY] = [
    .Food,
    .Nightlife,
    .CultureSightseeing,
    .Fitness
]

var BG_CATEGORIES: [CATEGORY: String] = [
    .Food: "category_food",
    .Nightlife: "category-nightlife",
    .CultureSightseeing: "category-culture",
    .Fitness: "category-fitness2",
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

    // MARK: category titles
    class func categoryReadableString(category: CATEGORY) -> String {
        switch category {
        case .Food: return "Food & Casual Drink"
        case .Nightlife: return "Nightlife & Entertainment"
        case .CultureSightseeing: return "Culture & Sightseeing"
        case .Fitness: return "Fitness, Sport & Recreation"
        }
    }
    
    // MARK: custom search terms
    class func searchTerms(string: String) -> String? {
        guard let category = self.categoryForString(string) else { return nil }
        switch category {
        default:
            return category.rawValue
        }
    }
    
    class func interestsForCategory(category: CATEGORY) -> String {
        switch category {
        case .Food:
            return "food"
        case .Fitness:
            return "fitness"
        case .Nightlife:
            return "nightlife"
        case .CultureSightseeing:
            return "sightseeing"
        }
    }
}
