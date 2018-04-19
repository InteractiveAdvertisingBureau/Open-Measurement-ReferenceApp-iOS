//
//  File.swift
//  OM-Demo
//
//  Created by Alex Chugunov on 9/24/17.
//

import UIKit

enum AdUnits: Int {
    case banner300x250
    case native
    case video

    var title: String {
        switch self {
        case .banner300x250:
            return "HTML 300x250"
        case .video:
            return "Native VAST Video"
        case .native:
            return "Native Image"
        }
    }

    var segue: String {
        switch self {
        case .banner300x250:
            return "showBanner"
        case .video:
            return "showVideo"
        case .native:
            return "showNativeBanner"
        }
    }
}

class AdListViewController: UITableViewController {
    
    var adUnits = [AdUnits]()
    
    override func viewDidLoad() {
        adUnits.append(AdUnits.banner300x250)
        adUnits.append(AdUnits.video)
        adUnits.append(AdUnits.native)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return adUnits.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Server Path"
        case 1:
            return "Demos"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = Constants.ServerResource.baseURL.rawValue
            cell.textLabel?.textColor = UIColor.darkGray
            cell.isUserInteractionEnabled = false
            return cell
        case 1:
            let adUnit = adUnits[indexPath.row]
            cell.textLabel?.text = adUnit.title
            return cell
        default:
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adUnit = adUnits[indexPath.row]
        performSegue(withIdentifier: adUnit.segue, sender: self)
    }
}
