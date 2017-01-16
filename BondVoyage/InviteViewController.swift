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

class InviteViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    
    @IBOutlet weak var noActivitiesView: UILabel!
    
    var didSetupScroll: Bool = false
    
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
        let title = "End search?"
        let categoryString = self.category == nil ? "" : "for \(CategoryFactory.categoryReadableString(self.category!)) "
        let message = "You will no longer be matched \(categoryString)if you go back. You can start another search at any time."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "End", style: .default, handler: { (action) in
            Activity.cancelCurrentActivity { (success, error) in
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
        guard let user = PFUser.current(), let activity = user.value(forKey: "activity") as? Activity else {
            return
        }
        guard let activities = self.activities, self.currentPage() < activities.count else { return }
        guard let selectedUser: PFUser = activities[self.currentPage()].object(forKey: "owner") as? PFUser else { return }
        
        let activityId = activity.objectId
        Activity.inviteToJoinActivity(activityId: activityId!, inviteeId: selectedUser.objectId!, completion:{ (activity, conversation, error) in
            let name = selectedUser.value(forKey: "firstName") as? String ?? selectedUser.value(forKey: "username") as? String ?? "this person"
            if let activity = activity {
                self.simpleAlert("Invite sent", message: "You have invited \(name) to bond. If accepted, you will be able to chat.")
            }
            else if let conversation = conversation {
                let message = "You have matched with \(name). Click to go chat"
                self.simpleAlert("You have a new bond", message: message, completion: { 
                    self.goToChat(selectedUser, conversation: conversation)
                })
            }
        })
    }
    
    func goToChat(_ selectedUser: PFUser, conversation: Conversation?) {
        guard let currentUser = PFUser.current(), let currentUserId = currentUser.objectId, let selectedUserId = selectedUser.objectId, let conversation = conversation else {
            print("goToChat failed")
            return
        }
        
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
    
    func goToJoinActivity(_ activity: PFObject) {
        self.activityIndicator.startAnimating()

        ActivityRequest.joinActivity(activity, suggestedPlace: nil, completion: { (results, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            if error != nil {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to join activities.", completion: { () -> Void in
                        UserService.logout()
                    })
                    return
                }
            }
            else {
                self.refresh()
                self.navigationController!.popToRootViewController(animated: true)
            }
        })
    }

    func currentPage() -> Int {
        let page = Int(floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width))
        return page
    }
    
    func setupScroll() {
        guard let activities = self.activities else {
            return
        }

        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = self.scrollView.frame.size.height
        self.scrollView.isPagingEnabled = true

        var count = 0
        for i in 0 ..< activities.count {
            let activity = activities[i]
            guard let user = activity.object(forKey: "owner") as? PFUser else { continue }
            count += 1
            let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
            controller.selectedUser = user
            
            controller.willMove(toParentViewController: self)
            self.addChildViewController(controller)
            self.scrollView.addSubview(controller.view)
            let frame = CGRect(x: width * CGFloat(i), y: 0, width: width, height: height)
            controller.view.frame = frame
            controller.didMove(toParentViewController: self)
            controller.configureUI() // force resize
        }
        self.scrollView.contentSize = CGSize(width: CGFloat(count) * width, height: height)
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
        }
        else {
            // users exist
            self.noActivitiesView.isHidden = true
            self.navigationItem.rightBarButtonItem?.customView?.alpha = 1
        }
    }
}
