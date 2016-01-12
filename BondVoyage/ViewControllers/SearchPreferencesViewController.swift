//
//  SearchPreferencesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/12/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class SearchPreferencesViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var genderFilterView: GenderFilterView!
    @IBOutlet weak var ageFilterView: AgeRangeFilterView!
    @IBOutlet weak var groupFilterView: GroupSizeFilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "close")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "save")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func save() {
        
        self.close()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
