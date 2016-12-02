//
//  CityViewController.swift
//  
//
//  Created by Tom Strissel on 11/1/16.
//
//

import UIKit

class CityViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CITIES"
        // Do any additional setup after loading the view.
        self.tableView.separatorStyle = .none
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        case 0: return "Boston"
        case 1: return "Athens"
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
        return 250
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0: print("tapped boston")
        case 1: print("tapped athens")
        case 2: print("push new city screen")
        default: print("other")
        }
    }
}
