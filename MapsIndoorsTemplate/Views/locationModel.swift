//
//  locationModel.swift
//  SinglePageMap
//
//  Created by Malte Myhlendorph on 30/03/2022.
//

import Foundation

struct Location: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var category: String
    var area: String
    var description: String
}
