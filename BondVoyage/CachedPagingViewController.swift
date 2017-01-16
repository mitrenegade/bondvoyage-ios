//
//  CachedPagingViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/16/17.
//  Copyright © 2017 RenderApps. All rights reserved.
//

import UIKit
import Parse

protocol CachedPagingViewControllerDelegate {
    func activePageChanged(page: Int)
}

class CachedPagingViewController: UIPageViewController {
    
    // FIXME: controller doesn't work well cached.
    //var pages: [Int: UIViewController] = [Int:UIViewController]()

    var activities: [Activity]?
    var cachedPagingDelegate: CachedPagingViewControllerDelegate?
    
    var currentPage: Int = -1
    var activePage: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func controllerAt(index: Int) -> UIViewController? {
        guard index >= 0 else { return nil }
        
        /*
        if let controller = self.pages[index] {
            return controller
        }
        else {
 */
            guard let activities = self.activities, index < activities.count else { return nil }
            let activity = activities[index]
            guard let user = activity.object(forKey: "owner") as? PFUser else { return nil }

            let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
            controller.selectedUser = user

//            self.pages[index] = controller
            
            return controller
//        }
    }
}

extension CachedPagingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    // MARK: UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        activePage = pendingViewControllers.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            if previousViewControllers.last != nil {
                self.cachedPagingDelegate?.activePageChanged(page: currentPage)
            }
        }
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var previousController: UIViewController?
        
        if currentPage > 0 {
            previousController = controllerAt(index: currentPage - 1)
        }
        
        return previousController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var nextController: UIViewController?
        
        if currentPage >= 0 && currentPage + 1 < self.activities?.count ?? 0 {
            nextController = controllerAt(index: currentPage + 1)
        }
        
        return nextController
    }
}
