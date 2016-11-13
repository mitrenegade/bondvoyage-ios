//
//  UserService.swift
//  BondVoyage
//
//  Created by Bobby Ren on 8/13/16.
//  Copyright © 2016 Bobby Ren. All rights reserved.
//
// Manages loading of PFUsers and their related QBUUsers

import UIKit
import Parse
import Quickblox

class QBUserService: NSObject {
    static let sharedInstance: QBUserService = QBUserService()
    var isRefreshingSession: Bool = false
    
    // MARK: Create User
    func createQBUser(_ parseUserId: String, completion: @escaping ((_ user: QBUUser?)->Void)) {
        let user = QBUUser()
        user.login = parseUserId
        user.password = parseUserId
        QBRequest.signUp(user, successBlock: { (response, user) in
            print("results: \(user)")
            completion(user)
        }) { (errorResponse) in
            print("Error: \(errorResponse)")
            completion(nil)
        }
    }
    
    // Mark: Login user
    func loginQBUser(_ parseUserId: String, completion: @escaping ((_ success: Bool, _ error: NSError?)->Void)) {
        QBRequest.logIn(withUserLogin: parseUserId, password: parseUserId, successBlock: { (response, user) in
            print("results: \(user)")
            user?.password = parseUserId // must set it again to connect to QBChat
            QBChat.instance().connect(with: user!) { (error) in
                if error != nil {
                    print("error: \(error)")
                    completion(false, error as NSError?)
                }
                else {
                    completion(true, nil)
                }
            }
        }) { (errorResponse) in
            print("Error: \(errorResponse)")
            
            if errorResponse.status.rawValue == 401 {
                // try creating, then logging in again
                self.createQBUser(parseUserId, completion: { (user) in
                    if let _ = user {
                        self.loginQBUser(parseUserId, completion: completion)
                    }
                    else {
                        completion(false, nil)
                    }
                })
            }
            else {
                completion(false, nil)
            }
        }
    }
    
    func logoutQBUser() {
        if QBChat.instance().isConnected {
            QBChat.instance().disconnect(completionBlock: { (error) in
                print("error: \(error)")
            })
        }
    }

    // load a QBUUser from cache by QBUserId
    class func qbUUserWithId(_ userId: UInt, loadFromWeb: Bool = false, completion: @escaping ((_ result: QBUUser?) -> Void)){
        if let user = self.cachedUserWithId(userId) {
            completion(user)
            return
        }
        if loadFromWeb {
            QBRequest.user(withID: userId, successBlock: { (response, user) in
                completion(user)
            }) { (response) in
                completion(nil)
            }
        }
        else {
            completion(nil)
        }
    }
    
    class func cachedUserWithId(_ userId: UInt) -> QBUUser? {
        return SessionService.sharedInstance.usersService.usersMemoryStorage.user(withID: userId)
    }
    
    // load a QBUUser from web based on a PFUser
    class func getQBUUserFor(_ user: PFUser, completion: @escaping ((_ result: QBUUser?)->Void)) {
        guard let objectId = user.objectId else {
            completion(nil)
            return
        }
        self.getQBUUserForPFUserId(objectId, completion: completion)
    }
    
    class func getQBUUserForPFUserId(_ userId: String, completion: @escaping ((_ result: QBUUser?) -> Void)) {
        // TODO: can optimize to prevent extra web calls by storing qbUserId in PFUser object
        QBRequest.user(withLogin: userId, successBlock: { (response, user) in
            if let user = user {
                SessionService.sharedInstance.usersService.usersMemoryStorage.add(user)
            }
            completion(user)
        }) { (response) in
            completion(nil)
        }
    }

    // Loads all users from quickblox (paged)
    fileprivate class func loadUsersWithCompletion(_ completion: @escaping ((_ results: [QBUUser]?)->Void)) {
        let responsePage: QBGeneralResponsePage = QBGeneralResponsePage(currentPage: 0, perPage: 100)
        QBRequest.users(for: responsePage, successBlock: { (response, responsePage, users) in
            print("users received: \(users)")
            completion(users)
            
        }) { (response) in
            print("error with users response: \(response.error)")
        }
    }
}
