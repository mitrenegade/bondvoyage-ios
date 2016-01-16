//
//  PlacesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/16/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView

class PlacesViewController: UIViewController {
    
    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var buttonGo: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickButton(button: UIButton) {
        if button == self.buttonGo {
            print("Go")
        }
        else if button == self.buttonNext {
            print("Next")
        }
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
