//
//  FouriteViewController.swift
//  Climate
//
//  Created by Anjali on 1/3/21.
//

import UIKit

class FouriteViewController: UIViewController {

    @IBOutlet weak var fouriteListTableView : UITableView!
    var fouriteCityList = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let fouriteList = UserDefaults.standard.object(forKey: UserDefaults.Keys.fouriteList) as? [[String : String]] {
            fouriteCityList = fouriteList
            fouriteCityList.reverse()
            fouriteListTableView.reloadData()
        }
    }
}

extension FouriteViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fouriteCityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FouriteTableViewCell") as! FouriteTableViewCell
        let city =  fouriteCityList[indexPath.row].first?.key
        cell.cityName.text = city
        return cell
    }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
