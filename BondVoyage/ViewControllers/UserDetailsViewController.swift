//
//  UserDetailsViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/8/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView

class UserDetailsViewController: UIViewController, PagedViewController {

    var selectedUser: PFUser?
    var invitingUser: PFUser?
    
    @IBOutlet weak var scrollViewContainer: AsyncImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var educationLabel: UILabel!
    @IBOutlet weak var groupsLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var interestsView: UIView!
    @IBOutlet weak var constraintNameViewTopOffset: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var relevantInterests: [String]?
    var invitingActivity: PFObject?

    // MARK: PagedViewController
    var page: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameView.isHidden = true
        self.interestsView.isHidden = true
        
        if self.selectedUser != nil {
            self.selectedUser!.fetchInBackground(block: { (user, error) -> Void in
                self.configureDetailsForUser()
            })
        }
        else if self.invitingUser != nil {
            self.invitingUser!.fetchInBackground(block: { (user, error) -> Void in
                self.configureDetailsForUser()
            })
        }
        
        if self.navigationController != nil {
            self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
            self.title = "My Profile"
        }
        
        self.view!.backgroundColor = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailsViewController.configureDetailsForUser), name: NSNotification.Name(rawValue: "profile:updated"), object: nil)
    }

    func configureUI() {
        self.nameView.backgroundColor = Constants.BV_backgroundGrayColor()
        self.interestsView.backgroundColor = Constants.BV_backgroundGrayColor()
        self.constraintNameViewTopOffset.constant = self.view.frame.size.height - self.nameView.frame.size.height - self.interestsView.frame.size.height
        self.scrollViewContainer.contentMode = .scaleAspectFill
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(UserDetailsViewController.close))
        if self.invitingUser != nil {
            self.title = "Invitation"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Respond", style: .done, target: self, action: #selector(UserDetailsViewController.handleInvitation))
        }
        else {
            if selectedUser == PFUser.current() {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(UserDetailsViewController.goToEditProfile))
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.configureUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "profile:updated"), object: nil)
    }

    func configureDetailsForUser() {
        var user: User? = selectedUser as? User
        if self.selectedUser == nil {
            user = self.invitingUser as? User
        }
        if user == nil {
            return
        }
        
        self.nameView.isHidden = false
        self.interestsView.isHidden = false

        if let photoURL: String = user!.value(forKey: "photoUrl") as? String {
            self.scrollViewContainer.setValue(URL(string: photoURL), forKey: "imageURL")
            //self.scrollViewContainer.imageURL = NSURL(string: photoURL)
        }
        else if let photo: PFFile = user!.value(forKey: "photo") as? PFFile {
            self.scrollViewContainer.setValue(URL(string: photo.url!), forKey: "imageURL")
            //self.scrollViewContainer.imageURL = NSURL(string: photo.url!)
        }
        else {
            self.scrollViewContainer.image = UIImage(named: "profile")
        }

        if let city = user!.city, !city.isEmpty {
            self.cityLabel.text = city
            self.cityLabel.isHidden = false
        }
        else {
            self.cityLabel.isHidden = true
        }
        
        if let firstName = user!.value(forKey: "firstName") as? String {
            self.nameLabel.text = "\(firstName)"
        }
        else if let username = user!.value(forKey: "username") as? String {
            self.nameLabel.text = "\(username)"
        }
        
        var genderAgeString: String?  = nil
        if let gender = user!.value(forKey: "gender") as? String {
            genderAgeString = gender.capitalized
        }
        if let year = user!.value(forKey: "birthYear") as? Int {
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.year], from: Date())
            let currentYear = components.year
            let age = currentYear! - year
            if genderAgeString != nil {
                genderAgeString = "\(genderAgeString!), age: \(age)"
            }
            else {
                genderAgeString = "age: \(age)"
            }
        }
        self.genderAndAgeLabel.text = genderAgeString

        self.configureInterestsLabel()
    }

    func configureInterestsLabel() {
        var user: PFUser? = selectedUser
        if self.selectedUser == nil {
            user = self.invitingUser
        }
        if user == nil {
            return
        }

        if self.invitingActivity != nil {
            self.invitingActivity!.fetchInBackground(block: { (object, error) -> Void in
                if let categories: [String] = self.invitingActivity!.object(forKey: "categories") as? [String] {
                    var str = self.stringFromArray(categories)
                    if self.selectedUser != nil {
                        self.interestsLabel.attributedText = "Interests: \(str)".attributedString(str, size: 17)
                    }
                    else {
                        let categoryString = categories[0]
                        if let category = CategoryFactory.categoryForString(categoryString) {
                            str = CategoryFactory.categoryReadableString(category)
                        }
                        self.interestsLabel.attributedText = "Wants to bond over: \(str)".attributedString(str, size: 17) // todo: load match and set this to match category
                    }
                }
            })
        }
        else {
            self.interestsLabel.text = nil
        }

        if let about = user!.value(forKey: "about") as? String {
            self.aboutMeLabel.attributedText = "About me: \(about)".attributedString(about, size: 17)
        }
        else {
            self.aboutMeLabel.text = nil
        }
        
        if let countries = user!.value(forKey: "countries") as? String {
            self.countriesLabel.attributedText = "I have traveled to: \(countries)".attributedString(countries, size: 17)
        }
        else {
            self.countriesLabel.text = nil
        }

        if let occupation = user!.value(forKey: "occupation") as? String {
            self.occupationLabel.attributedText = "Occupation: \(occupation)".attributedString(occupation, size: 17)
        }
        else {
            self.occupationLabel.text = nil
        }
        

        if let languages = user!.value(forKey: "languages") as? String {
            self.languagesLabel.attributedText = "Languages: \(languages)".attributedString(languages, size: 17)
        }
        else {
            self.languagesLabel.text = nil
        }
        
        if let education = user!.value(forKey: "education") as? String {
            self.educationLabel.attributedText = "Education: \(education)".attributedString(education, size: 17)
        }
        else {
            self.educationLabel.text = nil
        }
    
        if let group = user!.value(forKey: "group") as? String, let g = Group(rawValue:group) {
            switch g {
            case .Solo:
                self.groupsLabel.text = "I am solo"
                break
            case .SignificantOther:
                self.groupsLabel.text = "I am with my significant other"
                break
            case .Family:
                self.groupsLabel.text = "I am with family"
                break
            case .Friends:
                self.groupsLabel.text = "I am with friends"
                break
            }
        }
        else {
            self.groupsLabel.text = nil
        }
    }

    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func goToPlaces() {
        // TODO: delete
    }
    
    func close() {
        // close modally
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func goToEditProfile() {
        self.performSegue(withIdentifier: "GoToEditProfile", sender: nil)
    }
    
    // MARK: - Invitation actions
    func handleInvitation() {
        let alert: UIAlertController = UIAlertController(title: "Respond to invitation", message: "Would you like to accept this invitation to bond?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Accept invitation", style: .default, handler: { (action) -> Void in
            self.goToAcceptInvitation()
        }))
        alert.addAction(UIAlertAction(title: "Decline invitation", style: .default, handler: { (action) -> Void in
            self.goToRejectInvitation()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func goToAcceptInvitation() {
        ActivityRequest.respondToJoin(self.invitingActivity!, joiningUserId: self.invitingUser!.objectId, responseType: "accepted") { (results, error) -> Void in
            if error != nil {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to accept invitations.", completion: { () -> Void in
                        UserService.logout()
                    })
                    return
                }
            }
            else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "activity:updated"), object: nil)
            }
        }
    }
    
    func goToRejectInvitation() {
        ActivityRequest.respondToJoin(self.invitingActivity!, joiningUserId: self.invitingUser!.objectId, responseType: "declined") { (results, error) -> Void in
            if error != nil {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to decline invitations.", completion: { () -> Void in
                        UserService.logout()
                    })
                    return
                }
            }
            else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "activity:updated"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)

            }
        }
    }

    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToEditProfile" {
            
        }
    }
    */
}
