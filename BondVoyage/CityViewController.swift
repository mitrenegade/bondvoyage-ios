//
//  CityViewController.swift
//  
//
//  Created by Tom Strissel on 11/1/16.
//
//

import UIKit
import Parse

enum CityName: String {
    case Boston
    case Athens
    case Other
}

protocol CityViewDelegate: class {
    func didFinishSelectCity()
}

class CityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: CityViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CITIES"
        // Do any additional setup after loading the view.
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        print("cancel")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension CityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell")!
        let nameLabel = (cell.viewWithTag(2)! as! UILabel)
        nameLabel.text = nameForRow(row: indexPath.row)
        nameLabel.textColor = .white
        let ratingImageView = (cell.viewWithTag(1)! as! UIImageView)
        ratingImageView.image = imageForRow(row: indexPath.row)
        return cell
    }

    func nameForRow(row: Int) -> String {
        switch(row) {
        case 0: return CityName.Boston.rawValue
        case 1: return CityName.Athens.rawValue
        default: return "Not Listed?\nRequest New City"
        }
    }

    func imageForRow(row: Int) -> UIImage {
        switch (row) {
        case 0: return UIImage(named: "city-boston")!
        case 1: return UIImage(named: "city-athens")!
        case 2: return UIImage(named: "city-manhattanblur")!
        default: return UIImage(named: "city-boston")!
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.tableView.frame.size.height) / 3
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            self.setCity(city: .Boston)
        case 1:
            self.setCity(city: .Athens)
        case 2:
            print("push new city screen")
            self.performSegue(withIdentifier: "toSuggestCity", sender: nil)
        default: print("other")
        }
    }
    
    func setCity(city: CityName) {
        print("selected city \(city.rawValue)")
        guard let user = PFUser.current() as? User else { return }
        user.city = city.rawValue
        user.saveInBackground { (success, error) in
            if let error = error as? NSError {
                self.simpleAlert("Could not set city", defaultMessage: "We could not update your city to \(city.rawValue)", error: error)
            }
            else {
                self.delegate?.didFinishSelectCity()
            }
        }
    }
}
