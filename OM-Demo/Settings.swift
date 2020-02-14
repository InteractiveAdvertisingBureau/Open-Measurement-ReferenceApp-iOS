//
//  Settings.swift
//  OM-Demo
//
//  Created by Justin Hines on 2/14/20.
//  Copyright © 2020 Open Measurement Working Group. All rights reserved.
//

class Settings {
    static let shared = Settings()

    private(set) var isPrerendering = false
    
    func prerender() {
        isPrerendering = true
    }
    
    func noPrerender() {
        isPrerendering = false
    }
}
