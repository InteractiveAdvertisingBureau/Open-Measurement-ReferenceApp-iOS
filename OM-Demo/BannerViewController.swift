//
//  HTMLBannerViewController.swift
//  OM-Demo
//
//  Created by Alex Chugunov on 9/24/17.
//


import Foundation

class HTMLBannerViewController: WebViewController {
    override var creativeURL: URL {
        //let creativeURL = Bundle.main.url(forResource: "banner", withExtension: "html")

        let creativeURL = URL(string: "http://localhost:8000/creative/index.html")
        return creativeURL!
    }
}
