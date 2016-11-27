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
    func startChatWithUser(_ user: QBUUser,_ conversation: Conversation, completion: @escaping ((_ success: Bool, _ dialog: QBChatDialog?) -> Void)) {
        let name = conversation.objectId!
        guard let currentUser = QBSession.current().currentUser else {
            print("cannot start chat if not logged in")
            completion(false, nil)
            return
        }
        
        let users = [user, currentUser]
        if let dialogId = conversation.dialogId {
            // join existing dialog
            self.chatService.loadDialog(withID: dialogId, completion: { (dialog) in
                completion(dialog != nil, dialog)
            })
        }
        else {
            // create new dialog
            self.chatService.createPrivateChatDialog(withOpponent: user) { (response, dialog) in
//            self.chatService.createGroupChatDialog(withName: name, photo: nil, occupants: users) { (response, dialog) in
                if let dialog = dialog {
                    completion(true, dialog)
                }
                else {
                    completion(false, nil)
                }
            }
        }
    }
    
    func loadDialogMessages(dialogId: String,  completion: @escaping ((_ response: QBResponse, _ messages: [QBChatMessage]?) -> Void)) {
        self.chatService.messages(withChatDialogID: dialogId) { (response, messages) in
            print("messages for dialogId \(dialogId): \(messages)")
            completion(response, messages)
        }
    }
    
    // MARK: Refresh user session
    func refreshChatSession(_ completion: ((_ success: Bool) -> Void)?) {
        // if not connected to QBChat. For example at startup
        // TODO: make this part of the Session service
        guard !isRefreshingSession else { return }
        isRefreshingSession = true
        
        guard let qbUser = QBSession.current().currentUser else {
            print("No qbUser, handle this error!")
            completion?(false)
            return
        }
        
        guard let pfUser = PFUser.current() else {
            completion?(false)
            return
        }
        
        qbUser.password = pfUser.objectId!
        QBChat.instance().connect(with: qbUser) { (error) in
            self.isRefreshingSession = false
            if error != nil {
                print("error: \(error)")
                completion?(false)
            }
            else {
                print("login to chat succeeded")
                completion?(true)
            }
        }
    }

    // MARK: QMChatServiceDelegate
    
    override func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        super.chatService(chatService, didAddMessageToMemoryStorage: message, forDialogID: dialogID)
        
        if authService.isAuthorized {
            handleNewMessage(message, dialogID: dialogID)
        }
    }
    
    func handleNewMessage(_ message: QBChatMessage, dialogID: String) {

    }

}
