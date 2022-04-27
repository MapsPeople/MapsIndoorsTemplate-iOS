//
//  ViewController.swift
//  MapsIndoors Template - IOS
//
//  Created by Christian Wolf Johannsen on 16/11/2021.
//

import UIKit
import SwiftUI
import GoogleMaps
import MapsIndoors

//Defining user roles
class ViewController: UIViewController {
    let VIPUserRole: [String] = [
        "VIPUserPermission1",
        "VIPUserPermission2",
        "VIPUserPermission3",
    ]
    let regularUserRole: [String] = [
        "RegularUserPermission1",
        "RegularUserPermission2",
        "RegularUserPermission3",
]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GMSServices.provideAPIKey(googleApiKey)
//        MapsIndoors.provideAPIKey(mapsIndoorsApiKey,
//                                  googleAPIKey: googleApiKey)

    }

    @IBAction func showMap() {
        MapsIndoors.provideAPIKey(mapsIndoorsApiKey,
                                  googleAPIKey: googleApiKey)
        let mapView = MapsIndoorsView(activeUserRoles: VIPUserRole)
        let mapViewController = UIHostingController(rootView: mapView)
        navigationController?.pushViewController(mapViewController, animated: true)
    }

    private var mapsIndoorsApiKey: String {
        get {
            return apiKeyFor(key: "MAPSINDOORS_API_KEY")
        }
    }
    
    private var googleApiKey: String {
        get {
            return apiKeyFor(key: "GOOGLE_API_KEY")
        }
    }
    
    private func apiKeyFor(key: String) -> String {
        guard let filePath = Bundle.main.path(forResource: "MapsIndoors-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'MapsIndoors-Info.plist'. Please make a copy of the sample MapsIndoors-Info.plist with your actual API keys.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: key) as? String else {
            fatalError("Couldn't find key '\(key)' in 'MapsIndoors-Info.plist'.")
        }
        if (value.starts(with: "_")) {
            fatalError("See how to get started and get API keys at https://docs.mapsindoors.com/ios/v3/getting-started/prerequisites/.")
        }
        return value
    }
}
