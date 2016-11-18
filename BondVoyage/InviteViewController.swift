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
    @IBOutlet weak var buttonUp: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    var didSetupScroll: Bool = false
    
    var category: CATEGORY?
//    var activities: [PFObject]?
    var people: [PFUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
        self.configureRightNavigationButton()
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
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func didClickInviteOrChat() {
        print("here")
        guard let users = self.people, self.currentPage() < users.count else { return }
        let selectedUser: PFUser = users[self.currentPage()]
        
        QBUserService.getQBUUserFor(selectedUser) { [weak self] user in
            guard let user = user else {
                print("no user")
                return
            }
            SessionService.sharedInstance.startChatWithUser(user, completion: { (success, dialog) in
                guard success else {
                    print("Could not start chat")
                    self?.simpleAlert("Could not start chat", defaultMessage: "There was an error starting a chat with this person", error: nil, completion: nil)
                    return
                }
                
                if let chatNavigationVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatNavigationViewController") as? UINavigationController,
                    let chatVC = chatNavigationVC.viewControllers[0] as? ChatViewController {
                    chatVC.dialog = dialog
                    self?.present(chatNavigationVC, animated: true, completion: {
                        //QBNotificationService.sharedInstance.currentDialogID = dialog?.ID!
                    })
                }
            })
        }    }
    
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
        guard let users = self.people else {
            return
        }

        let width: CGFloat = self.view.frame.size.width
        let height: CGFloat = self.scrollView.frame.size.height
        self.scrollView.isPagingEnabled = true

        for i in 0 ..< users.count {
            //let activity = self.activities![i]
            let user = users[i]
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
        self.scrollView.contentSize = CGSize(width: CGFloat(users.count) * width, height: height)
    }
    
    func refresh() {
        guard let users = self.people else {
            self.buttonUp.isHidden = true
            return
        }
        
        if users.count == 0 {
            self.buttonUp.isHidden = true
        }
        else {
            self.buttonUp.isHidden = false
        }
    }
}
