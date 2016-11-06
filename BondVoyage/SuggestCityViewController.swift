//
//  SuggestCityViewController.swift
//  
//
//  Created by Tom Strissel on 11/1/16.
//
//

import UIKit

class SuggestCityViewController: UIViewController {

    
    @IBOutlet var btnOther: UIButton!
    @IBOutlet var btnTampa: UIButton!
    @IBOutlet var btnPortland: UIButton!
    @IBOutlet var btnCharlotte: UIButton!
    @IBOutlet var btnVegas: UIButton!
    @IBOutlet var btnPhoenix: UIButton!
    @IBOutlet var btnLondon: UIButton!
    @IBOutlet var btnDenver: UIButton!
    
    var selectedCity : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapButton(sender: UIButton) {
        if sender != btnOther {
            selectedCity = (sender.titleLabel?.text)!
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let newCityCtlr = segue.destinationViewController as! SubmitCityViewController
        newCityCtlr.selectedCity = self.selectedCity
    }
    

}
