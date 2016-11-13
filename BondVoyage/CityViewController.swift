//
//  CityViewController.swift
//  
//
//  Created by Tom Strissel on 11/1/16.
//
//

import UIKit

class CityViewController: UIViewController {

    @IBOutlet var btnSuggest: UIButton!
    @IBOutlet var btnAthens: UIButton!
    @IBOutlet var btnBoston: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        if sender == btnSuggest {
            self.performSegue(withIdentifier: "toSuggestCity", sender: self)
        } else {
            self.performSegue(withIdentifier: "toActivities", sender: self)
        }
    }

}
