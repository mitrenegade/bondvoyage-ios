//
//  BVUser.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/12/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

class BVUser: NSObject {
    var id: Int = -1
    var name: String = ""
    var photo: NSData?
    var interests: [String]?
    
    convenience init?(info: [String: AnyObject]) {
        self.init()
        if let _id: Int = info["id"] as? Int {
            self.id = _id
        }
        else {
            // fail if id doesn't exist
            return nil
        }
        
        if let _name: String = info["name"] as? String {
            self.name = _name
        }
        else {
            // fail if id doesn't exist
            return nil
        }
        
        if let _interests: [String] = info["interests"] as? [String] {
            self.interests = _interests
            // don't fail if doesn't exist
        }
    }
    
    
}
