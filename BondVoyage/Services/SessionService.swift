//
//  VideoSessionService.swift
//  Lunr
//
//  Created by Bobby Ren on 10/4/16.
//  Copyright © 2016 Bobby Ren. All rights reserved.
//
// manages video sessions

//TODO: hang up on client side is not showing call summary
//Create charge on provider side if disconencted successfully

import UIKit
import Parse
import Quickblox
import QMServices

class SessionService: QMServicesManager {
    static var _instance: SessionService?
    static var sharedInstance: SessionService {
        get {
            if _instance != nil {
                return _instance!
            }
            _instance = SessionService()
            return _instance!
        }
    }
    var isRefreshingSession: Bool = false

    var currentDialogID = ""
    
    // MARK: Chat session
    func startChatWithUser(user: QBUUser, completion: ((success: Bool, dialog: QBChatDialog?) -> Void)) {
        self.chatService.createPrivateChatDialogWithOpponent(user) { (response, dialog) in
            if let dialog = dialog {
                completion(success: true, dialog: dialog)
            }
            else {
                completion(success: false, dialog: nil)
            }
        }
    }
    
    // MARK: Refresh user session
    func refreshChatSession(completion: ((success: Bool) -> Void)?) {
        // if not connected to QBChat. For example at startup
        // TODO: make this part of the Session service
        guard !isRefreshingSession else { return }
        isRefreshingSession = true
        
        guard let qbUser = QBSession.currentSession().currentUser else {
            print("No qbUser, handle this error!")
            completion?(success: false)
            return
        }
        
        guard let pfUser = PFUser.currentUser() else {
            completion?(success: false)
            return
        }
        
        qbUser.password = pfUser.objectId!
        QBChat.instance().connectWithUser(qbUser) { (error) in
            self.isRefreshingSession = false
            if error != nil {
                print("error: \(error)")
                completion?(success: false)
            }
            else {
                print("login to chat succeeded")
                completion?(success: true)
            }
        }
    }

    // MARK: QMChatServiceDelegate
    
    override func chatService(chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        super.chatService(chatService, didAddMessageToMemoryStorage: message, forDialogID: dialogID)
        
        if authService.isAuthorized {
            handleNewMessage(message, dialogID: dialogID)
        }
    }
    
    func handleNewMessage(message: QBChatMessage, dialogID: String) {

    }

}