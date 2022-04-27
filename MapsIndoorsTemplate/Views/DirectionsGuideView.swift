//
//  DirectionsGuideView.swift
//  MapsIndoors Template - IOS
//
//  Created by Christian Wolf Johannsen on 25/11/2021.
//

import SwiftUI
import MapsIndoors

struct DirectionsGuideView: View {
    @ObservedObject var mapState: MapsIndoorsMapState
    @Binding var bottomSheetPosition: CustomBottomSheetPosition
    @Binding var showingDirections: Bool
    @State private var errorFindingRoute: Error?
    
    @ViewBuilder
    var body: some View {
        PagingView(index: $mapState.routeLegIndex, maxIndex: legMaxIndex) {
            if let route = mapState.route, let routeLegs = route.legs {
                ForEach(routeLegs as! Array<MPRouteLeg>, id: \.self) { leg in
                    DirectionGuideLeg(legInstructions: LegInstructions(route: route, leg: leg, endLocation: mapState.selectedTargetLocation))
                        .animation(.linear)
                }.onAppear {
                    mapState.adjustZoom = false
                }
            } else {
                DirectionGuideLeg(legInstructions: nil, errorFindingRoute: errorFindingRoute)
            }
        }.onAppear {
            bottomSheetPosition = .middleBottom
            mapState.adjustZoom = false
            mapState.routeLegIndex = 0
            getRoute()
        }.onDisappear {
            mapState.adjustZoom = true
        }.valueChanged(value: bottomSheetPosition){ _ in
            if (bottomSheetPosition.rawValue > CustomBottomSheetPosition.middleBottom.rawValue && showingDirections){
                bottomSheetPosition = CustomBottomSheetPosition.middleBottom
            }
        }
    }
    
    var legMaxIndex: Int {
        (mapState.route?.legs?.count ?? 1) - 1
    }
    
    func getRoute() {
        mapState.directionsService.getDirectionsFrom(origin: mapState.selectedSourceLocation, toDestination: mapState.selectedTargetLocation, accessibilityUserRole: mapState.accessibilityUserRole,  useAccessibility: mapState.routeAccessibility) { foundRoute, error in
            errorFindingRoute = error
            mapState.route = foundRoute
            mapState.directionsRenderer.nextRouteLegButton?.addTarget(mapState.directionsRendererHelper, action: #selector(mapState.directionsRendererHelper?.nextLeg), for: .touchUpInside)
            mapState.directionsRenderer.previousRouteLegButton?.addTarget(mapState.directionsRendererHelper, action: #selector(mapState.directionsRendererHelper?.previousLeg), for: .touchUpInside)
        }
    }
}

struct DirectionsGuideHeaderView: View {
    @Binding var showingDirections: Bool
    @State var mapState: MapsIndoorsMapState
    @State private var destinationName: String = ""
    @State private var title: String = "To: "
    
    var body: some View {
        HStack {
            titel
            Spacer()
            closeButton
        }.onAppear(){
            destinationName = mapState.selectedTargetLocation?.name ?? ""
            title.append(destinationName)
        }
    }
    
    //Titel
    var titel: some View {
        Text(title)
            .font(.title)
            .scaledToFit()
            .minimumScaleFactor(0.01)
            .lineLimit(1)
    }
    //closeButton - which is using the closeButton component
    var closeButton: some View {
        Button(action: closeDirectionsGuideView) {
            CloseButton()
        }.padding(.bottom)
    }
    
    func closeDirectionsGuideView(){
        showingDirections = false
        mapState.route = nil
        mapState.mapControl?.selectedLocation = mapState.selectedTargetLocation
    }
}



class DirectionsGuideHelper {
    let mapState: MapsIndoorsMapState
    
    init(state: MapsIndoorsMapState) {
        mapState = state
    }
    
    @objc func nextLeg() {
        mapState.routeLegIndex += 1
    }
    
    @objc func previousLeg() {
        mapState.routeLegIndex -= 1
    }
}
