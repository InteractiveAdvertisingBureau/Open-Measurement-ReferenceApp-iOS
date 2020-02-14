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
    
    /**
     An audio ad played with AVPlayer
     */
    case nativeAudio
 

    var title: String {
        switch self {
        case .HTMLDisplay:
            return "HTML 300x250"
        case .nativeVideo:
            return "Native VAST Video"
        case .nativeDisplay:
            return "Native Image"
        case .nativeAudio:
            return "Native Audio"
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
        case .nativeAudio:
            return "showAudio"
            
        }
    }
}

/**
 Presents the user with the list of available ad units in a table view.
 Tapping on a table view cell opens a view controller that handles selected ad unit.
 */

class AdListViewController: UITableViewController {
    var adUnits: [AdUnit] = [.HTMLDisplay, .nativeVideo, .nativeDisplay, .nativeAudio]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : adUnits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "prerenderCell", for: indexPath)
            cell.textLabel?.text = "Prerender"
            
            let toggle = UISwitch()
            toggle.translatesAutoresizingMaskIntoConstraints = false
            toggle.addTarget(self, action: #selector(togglePrerendering(sender:)), for: .touchUpInside)
            
            cell.addSubview(toggle)
            
            let verticalConstraint = NSLayoutConstraint(item: toggle,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: cell,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0)
            let trailingMargin = NSLayoutConstraint(item: toggle,
                                                    attribute: .rightMargin,
                                                    relatedBy: .equal,
                                                    toItem: cell,
                                                    attribute: .rightMargin,
                                                    multiplier: 1.0,
                                                    constant: -20.0)
            cell.addConstraints([verticalConstraint, trailingMargin])
        } else {
            let adUnit = adUnits[indexPath.row]
            cell.textLabel?.text = adUnit.title
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adUnit = adUnits[indexPath.row]
        performSegue(withIdentifier: adUnit.segue, sender: self)
    }
    
    @objc func togglePrerendering(sender: UISwitch) {
        if Settings.shared.isPrerendering {
            Settings.shared.noPrerender()
            sender.isEnabled = false
        } else {
          Settings.shared.prerender()
            sender.isEnabled = true
        }
    }
}
