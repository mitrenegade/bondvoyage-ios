//
//  InviteViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import QMChatViewController
import ParseLiveQuery

class InviteViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    var didSetupScroll: Bool = false
    var pagingController: CachedPagingViewController! = CachedPagingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var currentPage: Int = -1
    
    @IBOutlet weak var noActivitiesView: UILabel!
    
    // live query for Parse objects
    let liveQueryClient = ParseLiveQuery.Client()
    var subscription: Subscription<Activity>?
    var isSubscribed: Bool = false

    var category: CATEGORY?
    var activities: [Activity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        self.configureRightNavigationButton()
        
        let categoryString = self.category == nil ? "your activity" : CategoryFactory.categoryReadableString(self.category!)
        self.noActivitiesView.text = "No one is currently available. When people search for \(categoryString) they will appear here."
        self.noActivitiesView.isHidden = true
        
        self.view.insertSubview(pagingController.view, belowSubview: noActivitiesView)
        
        self.subscribeToUpdates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didSetupScroll {
            didSetupScroll = true
            self.setupScroll()
        }
    }
    
    func configureRightNavigationButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.addTarget(self, action: #selector(didClickInviteOrChat), for: .touchUpInside)
        button.setImage(UIImage(named: "icon150"), for: UIControlState())
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        guard let category = self.category else {
            self.navigationController!.popToRootViewController(animated: true)
            return
        }
        
        let title = "End search?"
        let message = "Do you want to cancel this activity? You will no longer be matched for \(CategoryFactory.categoryReadableString(category)) if you cancel. Otherwise, you will be searchable for 24 hours."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Keep Browsing", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "New Search", style: .default, handler: { (action) in
            self.navigationController!.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel Activity", style: .default, handler: { (action) in
            Activity.cancelActivityForCategory(category: category) { (success, error) in
                if !success {
                    print("error: \(error)")
                    // TODO: try again
                }
                else {
                    self.navigationController!.popToRootViewController(animated: true)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func didClickInviteOrChat() {
        self.inviteToChat()
    }
        
    func inviteToChat() {
        guard let user = PFUser.current() else {
            self.simpleAlert("Unable to chat", message: "Please log out and log back in, and try again.")
            return
        }
        guard let activities = self.activities, self.currentPage < activities.count else {
            self.simpleAlert("Unable to chat", message: "There was an issue loading this activity.")
            return
        }
        guard let selectedUser: PFUser = activities[self.currentPage].object(forKey: "owner") as? PFUser, let inviteeId = selectedUser.objectId else {
            self.simpleAlert("Unable to chat", message: "Could not load the user to be invited.")
            return
        }
        guard let category = self.category else {
            self.simpleAlert("Unable to chat", message: "Invalid category. Please cancel your activity and try again.")
            return
        }
        
        Bond.inviteToBond(category: category, inviteeId: inviteeId) { (bond, conversation, error) in
            let name = selectedUser.value(forKey: "firstName") as? String ?? selectedUser.value(forKey: "username") as? String ?? "this person"
            if let conversation = conversation {
                let message = "You have matched with \(name). Click to go chat"
                self.simpleAlert("You have a new bond", message: message, completion: {
                    self.goToChat(selectedUser, conversation: conversation)
                })
            } else if let bond = bond {
                self.simpleAlert("Invite sent", message: "You have invited \(name) to bond. If accepted, you will be able to chat.")
            } else {
                print("error: \(error)")
                self.simpleAlert("Could not invite \(name)", defaultMessage: "There was an error inviting \(name) to bond.", error: error)
            }
        }
    }
    
    func goToChat(_ selectedUser: PFUser, conversation: Conversation?) {
        guard let currentUser = PFUser.current(), let currentUserId = currentUser.objectId, let selectedUserId = selectedUser.objectId, let conversation = conversation else {
            print("goToChat failed")
            return
        }
        
        return;
            
        QBUserService.getQBUUserFor(selectedUser) { [weak self] user in
            guard let user = user else {
                print("no user")
                return
            }
            SessionService.sharedInstance.startChatWithUser(user, conversation, completion: { (success, dialog) in
                guard success else {
                    print("Could not start chat")
                    self?.simpleAlert("Could not start chat", defaultMessage: "There was an error starting a chat with this person", error: nil, completion: nil)
                    return
                }
                
                if let chatNavigationVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatNavigationViewController") as? UINavigationController,
                    let chatVC = chatNavigationVC.viewControllers[0] as? ChatViewController {
                    chatVC.dialog = dialog
                    chatVC.conversation = conversation
                    self?.present(chatNavigationVC, animated: true, completion: {
                        //QBNotificationService.sharedInstance.currentDialogID = dialog?.ID!
                        // create conversation
                        if let dialogId = dialog?.id {
                            print("add dialog to conversation")
                            conversation.setValue(dialogId, forKey: "dialogId")
                            conversation.saveInBackground()
                        }
                    })
                }
            })
        }
    }
    
    func setupScroll() {
        guard let activities = self.activities else {
            return
        }

        self.pagingController.view.frame = self.scrollView.frame
        self.scrollView.removeFromSuperview()
        
        self.pagingController.activities = self.activities
        self.pagingController.cachedPagingDelegate = self
        
        if let activities = self.activities, activities.count > 0 {
            self.currentPage = 0
        }
        self.refresh()
    }
    
    func refresh() {
        guard let activities = self.activities else {
            return
        }
        
        if activities.count == 0 {
            // no users
            self.noActivitiesView.isHidden = false
            self.navigationItem.rightBarButtonItem?.customView?.alpha = 0.25
            
            self.currentPage = -1
            self.pagingController.view.isHidden = true
        }
        else {
            // users exist
            self.noActivitiesView.isHidden = true
            self.navigationItem.rightBarButtonItem?.customView?.alpha = 1
            
            if self.currentPage == -1 {
                self.currentPage = 0
            }
            
            guard let controller = self.pagingController.controllerAt(index: self.currentPage) else {
                return
            }
            self.pagingController.view.isHidden = false
            self.pagingController.setViewControllers([controller as! UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        }
    }
}

extension InviteViewController: CachedPagingViewControllerDelegate {
    func activePageChanged(index: Int) {
        self.currentPage = index
    }
}

// live query
extension InviteViewController {
    func subscribeToUpdates() {
        guard let user = PFUser.current(), let userId = user.objectId else { return }
        guard let query: PFQuery<Activity> = Activity.query() as? PFQuery<Activity> else { return }
        guard let categoryString = self.category?.rawValue else { return }
        
        query.whereKey("category", equalTo: categoryString.lowercased())
        
        // TODO: filter out owner = self, which can't be done because owner is a pointer
//        query.whereKey("owner.objectId", notEqualTo: userId)
        
        self.subscription = liveQueryClient.subscribe(query)
            .handle(Event.created) { _, object in
                if let owner = object.owner, let ownerId = owner["objectId"] as? String, ownerId == userId {
                    return
                }

                self.activities!.append(object)
                self.pagingController.activities = self.activities
                do {
                    try object.fetchOwnerInBackground(completion: { isNew in
                        self.pagingController.activities = self.activities
                        
                        if isNew {
                            // if the user was just fetched, then the existing PagingViewController will not load it correctly, and we must force a refresh
                            DispatchQueue.main.async(execute: {
                                self.refresh()
                            })
                        }
                    })
                } catch {
                    print("error in do try")
                }
            }
            .handle(Event.updated) { _, object in
                if let owner = object.owner, let ownerId = owner["objectId"] as? String, ownerId == userId {
                    return
                }
                
                if let activities = self.activities {
                    for a in activities {
                        if a.objectId == object.objectId {
                            self.activities!.remove(at: activities.index(of: a)!)
                        }
                    }
                }
                
                if object.status == "active" /*, let expiration = object.expiration, expiration.timeIntervalSinceNow > 0*/ {
                    do {
                        try object.fetchOwnerInBackground(completion: { isNew in
                            self.activities!.append(object)
                            DispatchQueue.main.async(execute: {
                                print("received update for activity: \(object.objectId!) owner \(object.owner)")
                                
                                self.pagingController.activities = self.activities
                                self.refresh()
                            })
                        })
                    } catch {
                        print("error in do try")
                    }
                }
                else {
                    DispatchQueue.main.async(execute: {
                        print("received update for activity: \(object.objectId!) owner \(object.owner)")
                        
                        self.pagingController.activities = self.activities
                        self.refresh()
                    })
                }
            }
            .handle(Event.deleted) { _, object in
                if let owner = object.owner, let ownerId = owner["objectId"] as? String, ownerId == userId {
                    return
                }
                print("here")
            }
        isSubscribed = true
    }
}
