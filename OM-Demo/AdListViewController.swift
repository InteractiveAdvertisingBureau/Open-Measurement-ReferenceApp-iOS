//
//  AdListViewController.swift
//  OM-Demo
//
//  Created by Alex Chugunov on 9/24/17.
//

import UIKit

/**
 Supported Ad Units
 */

enum AdUnit: Int {
    /**
     300x2500 standard HTML display banner rendered by WKWebView.
     */
    case HTMLDisplay

    /**
     A static image rendered by UIImageView
     */
    case nativeDisplay

    /**
     A video asset rendered by AVKit
     */
    case nativeVideo

    var title: String {
        switch self {
        case .HTMLDisplay:
            return "HTML 300x250"
        case .nativeVideo:
            return "Native VAST Video"
        case .nativeDisplay:
            return "Native Image"
        }
    }

    var segue: String {
        switch self {
        case .HTMLDisplay:
            return "showBanner"
        case .nativeVideo:
            return "showVideo"
        case .nativeDisplay:
            return "showNativeBanner"
        }
    }
}

/**
 Presents the user with the list of available ad units in a table view.
 Tapping on a table view cell opens a view controller that handles selected ad unit.
 */

class AdListViewController: UITableViewController {
    var adUnits: [AdUnit] = [.HTMLDisplay, .nativeVideo, .nativeDisplay]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adUnits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        let adUnit = adUnits[indexPath.row]
        cell.textLabel?.text = adUnit.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adUnit = adUnits[indexPath.row]
        performSegue(withIdentifier: adUnit.segue, sender: self)
    }
}
