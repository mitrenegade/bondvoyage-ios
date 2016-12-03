//
//  SuggestCityViewController.swift
//  
//
//  Created by Tom Strissel on 11/1/16.
//
//

import UIKit
import Parse

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
    
    
    @IBAction func didTapButton(_ sender: UIButton) {
        if sender != btnOther {
            if let city = sender.titleLabel?.text {
                self.performSegue(withIdentifier: "toSubmitCity", sender: city)
            }
        }
        else {
            self.performSegue(withIdentifier: "toSubmitCity", sender: nil)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! SubmitCityViewController
        controller.selectedCity = sender as? String
    }
    

}
