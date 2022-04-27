//
//  MapsIndoorsSearch.swift
//  MapsIndoors Template - IOS
//
//  Created by Christian Wolf Johannsen on 25/11/2021.
//

import Foundation
import MapsIndoors

class MapsIndoorsSearch {
    static func locationsFromQuery(searchText: String, nearPosition: MPPoint?, completion: @escaping ([MPLocation]) -> Void) {
        let query = MPQuery()
        let filter = MPFilter()
        
        query.query = searchText
        if nearPosition != nil{
            query.near = nearPosition!
        }
        filter.take = 100
        MPLocationService.sharedInstance().getLocationsUsing(query, filter: filter) { (locations, error) in
            completion(locations ?? [])
        }
    }
    
    static func removeViewingAngle(state: MapsIndoorsMapState) {
        if let camera = state.mapView?.camera {
            state.mapView?.camera = GMSCameraPosition.camera(withLatitude: camera.target.latitude, longitude: camera.target.longitude, zoom: camera.zoom, bearing: camera.bearing, viewingAngle: 0)
        }
    }
}
