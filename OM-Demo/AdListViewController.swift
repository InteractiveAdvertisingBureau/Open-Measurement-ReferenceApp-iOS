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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        if let adUnit = AdUnits(rawValue: indexPath.row) {
            cell.textLabel?.text = adUnit.title
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let adUnit = AdUnits(rawValue: indexPath.row) {
            performSegue(withIdentifier: adUnit.segue, sender: self)
        }
    }
}
