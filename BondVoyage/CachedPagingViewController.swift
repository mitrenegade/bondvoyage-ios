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
    func activePageChanged(index: Int)
}

protocol PagedViewController {
    var page: Int { get set }
}

class CachedPagingViewController: UIPageViewController {
    
    // FIXME: controller doesn't work well cached.
    //var pages: [Int: UIViewController] = [Int:UIViewController]()

    var activities: [Activity]?
    var cachedPagingDelegate: CachedPagingViewControllerDelegate?
    
    var activePage: PagedViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
    }
    
    func controllerAt(index: Int) -> PagedViewController? {
        guard index >= 0 else { return nil }
        
        /*
        if let controller = self.pages[index] {
            return controller
        }
        else {
 */
        guard let activities = self.activities, index < activities.count else { return nil }
        let activity = activities[index]
        
        let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
        controller.page = index
        
        controller.selectedUser = activity.owner
        //            self.pages[index] = controller
        
            return controller
//        }
    }
}

extension CachedPagingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    // MARK: UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        activePage = pendingViewControllers.last as? PagedViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            if previousViewControllers.last != nil {
                let currentPage = activePage?.page ?? 0
                self.cachedPagingDelegate?.activePageChanged(index: currentPage)
            }
        }
        else {
            let currentPage = activePage?.page ?? 0
            self.cachedPagingDelegate?.activePageChanged(index: currentPage)
        }
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var previousController: UIViewController?
        
        let currentPage = activePage?.page ?? 0
        if currentPage > 0 {
            previousController = controllerAt(index: currentPage - 1) as? UIViewController
        }
        
        return previousController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var nextController: UIViewController?
        
        let currentPage = activePage?.page ?? 0
        if currentPage >= 0 && currentPage + 1 < self.activities?.count ?? 0 {
            nextController = controllerAt(index: currentPage + 1) as? UIViewController
        }
        
        return nextController
    }
}
