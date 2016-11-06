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

class SessionService: QMServicesManager, QBRTCClientDelegate {
    static var _instance: SessionService?
    static var sharedInstance: SessionService {
        get {
            if _instance != nil {
                return _instance!
            }
            _instance = SessionService()
            QBRTCClient.initializeRTC()
            QBRTCClient.instance().addDelegate(_instance)
            QBRTCConfig.setAnswerTimeInterval(SESSION_TIMEOUT_INTERVAL)
            return _instance!
        }
    }
    var session: QBRTCSession?
    var incomingSession: QBRTCSession?
    var isRefreshingSession: Bool = false

    var currentDialogID = ""
    var remoteVideoTrack: QBRTCVideoTrack?
    
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

    
    // MARK: Session lifecycle
    
    // delegate (client)
    func didReceiveNewSession(session: QBRTCSession!, userInfo: [NSObject : AnyObject]!) {
        self.incomingSession = session
        if (self.session != nil) {
            // automatically reject call if a session exists
            return
        }
        
        let userId = self.incomingSession!.initiatorID as UInt
        QBUserService.qbUUserWithId(userId) { (result) in
            if let user = result {
                print("Incoming call from a known user with id \(user.ID)")
                if let pfObjectId = userInfo["callId"] as? String {
//                    CallService.sharedInstance.currentCallId = pfObjectId
                }

                self.session = self.incomingSession
//                self.state = .Connected
            }
            else {
                self.incomingSession = nil
                print("UserID could not be loaded")
            }
        }
    }
    
    // user action (client)
    func acceptCall(userInfo: [String: AnyObject]?) {
        // happens automatically when client receives an incoming call and goes to video view
        self.session?.acceptCall(userInfo)
    }
    
    func rejectCall(userInfo: [String: AnyObject]?) {
        // might happen if client is already in a call and goes to video view...shouldn't happen
        self.session?.rejectCall(userInfo)
    }
    
    // delegate (provider)
    func session(session: QBRTCSession!, acceptedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        print("call accepted")
    }
    
    func session(session: QBRTCSession!, rejectedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        print("call rejected")
    }
    
    // delegate (both - video received)
    func session(session: QBRTCSession!, initializedLocalMediaStream mediaStream: QBRTCMediaStream!) {
    }
    
    func session(session: QBRTCSession!, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack!, fromUser userID: NSNumber!) {
        self.remoteVideoTrack = videoTrack // store it
    }
    
    func endCall() {
        self.session?.hangUp(nil)
        self.currentDialogID = ""
    }

    // MARK: All connections
    func session(session: QBRTCSession!, hungUpByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        print("session hung up")
        self.session = nil
    }
    
    func sessionDidClose(session: QBRTCSession!) {
        print("Session closed")
        // notified when all remotes are inactive
        self.session = nil
    }
    
}