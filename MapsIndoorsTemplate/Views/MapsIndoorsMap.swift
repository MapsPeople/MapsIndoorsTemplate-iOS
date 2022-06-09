//
//  MapsIndoorsMap.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 18/11/2021.
//

import SwiftUI
import GoogleMaps
import MapsIndoors



class MapsIndoorsMapState : ObservableObject {
    @Published var selectedVenue : MPVenue?
    @Published var focusedBuilding : MPLocation?
    @Published var selectedTargetLocation : MPLocation? {
        didSet {
            mapControl?.selectedLocation = selectedTargetLocation
            mapControl?.searchResult = nil
            mapControl?.showSearchResult(false)
        }
    }
    @Published var selectedSourceLocation : MPLocation?
    @Published var initialMapCamera : GMSCameraPosition
    @Published var selectedFloor: NSNumber? {
        didSet {
            mapControl?.currentFloor = selectedFloor
        }
    }
    @Published var routeLegIndex: Int {
        didSet {
            if route != nil {
                directionsRenderer.routeLegIndex = routeLegIndex
                directionsRenderer.animate(5)
            }
        }
    }
    var directionsService = MapsIndoorsDirections()
    var route: MPRoute? {
        didSet {
            directionsRenderer.route = route
            if route != nil {
                directionsRenderer.routeLegIndex = routeLegIndex
            }
        }
    }
    @Published var routeAccessibility = false
    @Published var didFinishLoading: Bool = false
    @Published var adjustZoom: Bool = true
    
    var mapControl : MPMapControl?
    let directionsRenderer = MPDirectionsRenderer()
    var directionsRendererHelper: DirectionsGuideHelper?
    var mapView: GMSMapView?
    var accessibilityUserRole: MPUserRole?
    var activeUserRoles: [MPUserRole]?
    let venueProvider = MPVenueProvider.init()
    
    init(camera: GMSCameraPosition?, floor: NSNumber?) {
        let startCamera = camera ?? GMSCameraPosition.camera(withLatitude: 57.05, longitude: 9.95, zoom: 15)
        initialMapCamera = startCamera
        selectedFloor = floor
        routeLegIndex = 0
        route = nil
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: startCamera)
        mapView?.settings.compassButton = true
        directionsRenderer.map = mapView
        directionsRenderer.fitBounds = true
        directionsRendererHelper = DirectionsGuideHelper(state: self)
        mapControl = MPMapControl.init(map: mapView!)!
        venueProvider.getVenuesWithCompletion { (venueColl, error) in
            if error == nil {
                let bounds = (venueColl!.venues?.first as! MPVenue).getBoundingBox()
                self.mapView?.animate(with: GMSCameraUpdate.fit(bounds!))
                self.mapView?.animate(toZoom: 17)
            }
        }

        mapControl?.showUserPosition(true)
        MapsIndoors.positionProvider = GPSPositionProvider()
        MapsIndoors.positionProvider?.startPositioning(nil)

        findAccessbilityRole()
        loadDefaultMapStyle()
    }
    
    func loadDefaultMapStyle() {
        if let styleUrl = Bundle.main.url(forResource: "default_googlemaps_style", withExtension: "json") {
            if let style = try? GMSMapStyle(contentsOfFileURL: styleUrl) { mapView?.mapStyle = style }
        }
    }
    
    func updateMap(){
        if let loc = self.mapControl?.selectedLocation {
            self.mapControl?.go(to: loc)
        }
    }
    
    func applyUserRoles(_ userRoles: [String]) {
        MPSolutionProvider().getUserRoles { allUserRoles, error in
            self.activeUserRoles = allUserRoles?.filter({ role in
                userRoles.contains(role.userRoleName)
            })
            MapsIndoors.userRoles = self.activeUserRoles
        }
    }
    
    func findAccessbilityRole() {
        MPSolutionProvider().getUserRoles { allUserRoles, error in
            self.accessibilityUserRole = allUserRoles?.first(where: { role in
                role.userRoleName == "Accessibility"
            })
        }
    }
}


struct MapsIndoorsMap: UIViewRepresentable {
    typealias UIViewType = GMSMapView
    
    @ObservedObject var state : MapsIndoorsMapState
    
    init(mapState : MapsIndoorsMapState) {
        state = mapState
    }
    
    func makeUIView(context: Context) -> UIViewType {
        return state.mapView!
    }
    
    func updateUIView(_ mapView: UIViewType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MPMapControlDelegate, MPDirectionsRendererDelegate, GMSMapViewDelegate {
        var mapsIndoorsMap : MapsIndoorsMap
        
        init(_ mapsIndoorsMap: MapsIndoorsMap) {
            self.mapsIndoorsMap = mapsIndoorsMap
            super.init()
            
            mapsIndoorsMap.state.mapControl?.currentFloor = mapsIndoorsMap.state.selectedFloor
            mapsIndoorsMap.state.mapControl?.delegate = self
            mapsIndoorsMap.state.mapView?.delegate = self
            mapsIndoorsMap.state.directionsRenderer.delegate = self
        }
        
        func focusedBuildingDidChange(_ building: MPLocation?) {
            mapsIndoorsMap.state.focusedBuilding = building
        }
        
        func didTap(at coordinate: CLLocationCoordinate2D, with locations: [MPLocation]?) -> Bool {
            let fallbackCamera = mapsIndoorsMap.state.mapView?.camera.target ?? mapsIndoorsMap.state.initialMapCamera.target
            if let mc = self.mapsIndoorsMap.state.mapControl {
                if let loc = locations?.first {
                    mc.selectedLocation = loc
                    if !mapsIndoorsMap.state.adjustZoom {
                        mapsIndoorsMap.state.mapView?.animate(toLocation: loc.geometry?.getCoordinate() ?? fallbackCamera)
                        return false
                    }
                }
            }
            
            return true
        }
        
        func didTap(_ marker: GMSMarker, forLocationCluster locations: [MPLocation]?, moreZoomPossible: Bool) -> Bool {
            return true
        }
        
        func mapContentReady() {
            self.mapsIndoorsMap.state.didFinishLoading.toggle()
        }
        
        func floorDidChange(_ floor: NSNumber) {
            mapsIndoorsMap.state.selectedFloor = floor
            
            // Clear selection on floor change:
            if let mc = mapsIndoorsMap.state.mapControl {
                mc.selectedLocation = nil
            }
        }
    }
}



