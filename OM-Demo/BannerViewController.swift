//
//  HTMLBannerViewController.swift
//  OM-Demo
//
//  Created by Alex Chugunov on 9/24/17.
//


import Foundation

class HTMLBannerViewController: WebViewController {
    override var creativeURL: URL {
        guard let creativeURL = URL(string: Constants.ServerResource.bannerAd.rawValue) else {
            fatalError("Unable to access resource: \(Constants.ServerResource.bannerAd)")
        }
        return creativeURL
    }
}
