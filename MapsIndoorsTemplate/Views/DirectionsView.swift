//
//  DirectionsView.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 19/11/2021.
//

import SwiftUI
import BottomSheetSwiftUI
import MapsIndoors
import Combine

// Show this view only after the user has pressed "get directions" from the detailview
struct DirectionsView: View {
    @Binding var bottomSheetPosition: CustomBottomSheetPosition
    @ObservedObject var state: MapsIndoorsMapState
    @Binding var gettingDirections: Bool
    @Binding var showingDirections: Bool
    
    @State private var sourceSearchText = ""
    @State private var sourceSearchResult = [MPLocation]()
    @State private var sourceLocation: MPLocation?
    @State private var isSearchingSource = false
    
    @State private var targetSearchText = ""
    @State private var targetSearchResult = [MPLocation]()
    @State private var targetLocation: MPLocation?
    @State private var isSearchingTarget = false
    @State private var initialised = false

    private var myLocation: Binding<MPLocation?> { Binding(
        get: {
            guard let positionResult = MapsIndoors.positionProvider?.latestPositionResult else {
                return nil
            }

            let myLocationUpdate = MPLocationUpdate(location: MPLocation())
            myLocationUpdate.name = "My Position"
            myLocationUpdate.position = positionResult.geometry?.getCoordinate() ?? CLLocationCoordinate2D()
            myLocationUpdate.floor = positionResult.getFloor()?.intValue ?? 0
            myLocationUpdate.type = "my-location"
            return myLocationUpdate.location()
        },
        set: { _ in }
        )
    }
    
    @ViewBuilder
    var transparentView: some View {
        Color(UIColor.systemBackground)
            .opacity(0.01)
    }
    
    var body: some View {
        ZStack{
            transparentView.onTapGesture {
                HeaderTap.tap()
            }
            VStack (alignment: .leading) {
                FromSearchBar(sourceSearchText: $sourceSearchText, sourceSearchResult: $sourceSearchResult, isSearchingSource: $isSearchingSource, sourceLocation: $sourceLocation, myLocation: myLocation)
                    .onTapGesture {
                        isSearchingSource = true
                        isSearchingTarget = false
                        restoreTargetLocation()
                        bottomSheetPosition = .top
                        removeViewingAngle()
                    }
                ToSearchBar(targetSearchText: $targetSearchText, targetSearchResult: $targetSearchResult, isSearchingTarget: $isSearchingTarget, targetLocation: $targetLocation, myLocation: myLocation)
                    .onTapGesture {
                        isSearchingSource = false
                        isSearchingTarget = true
                        restoreSourceLocation()
                        bottomSheetPosition = .top
                        removeViewingAngle()
                    }
                // Show Selected Location (target) information
                UtilityBar(sourceSearchText: $sourceSearchText, targetSearchText: $targetSearchText, sourceLocation: $sourceLocation, targetLocation: $targetLocation, state: state)
                // If the user is currently searching (has a search window open)
                if (isSearchingSource || isSearchingTarget){
                    // If the user is *typing* into the source text field
                    if (isSearchingSource) {
                        ResultList(searchText: $sourceSearchText, resultList: $sourceSearchResult, myLocation: myLocation)
                            .onReceive(ResultList.selection) { Output in
                                selectSourceLocation(location: Output)
                            }
                            .frame(minHeight: 200)
                    }
                    // Else if the user is currently *typing* into the target text field.
                    if (isSearchingTarget) {
                        ResultList(searchText: $targetSearchText, resultList: $targetSearchResult, myLocation: myLocation)
                            .onReceive(ResultList.selection) { Output in
                                selectTargetLocation(location: Output)
                                state.mapControl?.selectedLocation = Output
                                state.updateMap()
                            }
                            .frame(minHeight: 200)
                    }
                    
                } else {
                    Spacer()
                    GetDirectionsButton(sourceLocation: $sourceLocation, targetLocation: $targetLocation, state: state)
                        .onReceive(GetDirectionsButton.approved) { Output in
                            getRouteGuide(source: sourceLocation, target: targetLocation)
                        }
                }
                // When this view appears, make sure we pre-emptively fill in the target location based on the location the user had in the detailview
            }.onAppear{
                bottomSheetPosition = .middle
                targetSearchText = state.mapControl?.selectedLocation?.name ?? ""
                targetLocation = state.mapControl?.selectedLocation
                initialised = true
                if (state.selectedSourceLocation != nil){
                    sourceLocation = state.selectedSourceLocation
                    sourceSearchText = sourceLocation?.name ?? ""
                }
            }.onDisappear{
                initialised = false
            }.onReceive(HeaderTap.didTap) { Output in
                if (isSearchingSource || isSearchingTarget){
                    deFocus()
                }
            }.valueChanged(value: state.mapControl?.selectedLocation) { _ in
                if (state.mapControl?.selectedLocation != targetLocation && state.mapControl?.selectedLocation != nil && initialised){
                    gettingDirections = false
                }
            }
        }
    }
    
    func deFocus(){
        isSearchingSource = false
        restoreSourceLocation()
        isSearchingTarget = false
        restoreTargetLocation()
        bottomSheetPosition = .middle
        dismissKeyboard()
    }
    
    func restoreSourceLocation(){
        sourceSearchText = sourceLocation?.name ?? sourceSearchText
    }
    
    func restoreTargetLocation(){
        targetSearchText = targetLocation?.name ?? targetSearchText
    }
    
    func selectSourceLocation(location:MPLocation){
        sourceSearchText = location.name ?? ""
        sourceLocation = location
        isSearchingSource = false
        bottomSheetPosition = .middle
        dismissKeyboard()
    }
    
    func selectTargetLocation(location:MPLocation){
        targetSearchText = location.name ?? ""
        targetLocation = location
        isSearchingTarget = false
        bottomSheetPosition = .middle
        dismissKeyboard()
    }
    
    func getRouteGuide(source: MPLocation?, target: MPLocation?){
        showingDirections = true
        state.selectedTargetLocation = target
        state.selectedSourceLocation = source
    }
    
    func removeViewingAngle(){
        MapsIndoorsSearch.removeViewingAngle(state: state)
    }
    
    struct FromSearchBar: View {
        @Binding var sourceSearchText: String
        @Binding var sourceSearchResult: [MPLocation]
        @Binding var isSearchingSource: Bool
        @Binding var sourceLocation:MPLocation?
        @Binding var myLocation: MPLocation?

        var body: some View {
            VStack {
                HStack {
                    Text("From: ")
                    startingPoint
                    if (sourceSearchText != "") {
                    clearButton
                    }
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("SearchBar")))
                if (isSearchingSource == false){
                    LocationInformationFloorArea(location: sourceLocation)
                        .onTapGesture {
                            HeaderTap.tap()
                        }
                }
            }
        }
        
        //Starting point text field
        var startingPoint: some View {
            TextField("Find starting point", text: $sourceSearchText)
                .valueChanged(value: sourceSearchText) {_ in
                    MapsIndoorsSearch.locationsFromQuery(searchText: sourceSearchText, nearPosition: nil) { locations in
                        sourceSearchResult = locations
                        if let userLocation = myLocation {
                            sourceSearchResult.insert(userLocation, at: 0)
                        }
                    }
                }
        }
        
        //Clear search bar button
        var clearButton: some View {
            Button (action: {
                sourceSearchText = ""
                sourceLocation = nil
            }) {
                Image("clear")
                    .renderingMode(.template)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
    }
    
    struct ToSearchBar: View {
        @Binding var targetSearchText: String
        @Binding var targetSearchResult: [MPLocation]
        @Binding var isSearchingTarget: Bool
        @Binding var targetLocation:MPLocation?
        @Binding var myLocation: MPLocation?

        var body: some View {
            VStack {
                HStack {
                    Text("To: ")
                    findDestinationTextField
                    if (targetSearchText != "") {
                        Button(action: {
                            targetSearchText = ""
                            targetLocation = nil
                        }) {
                            Image("clear")
                                .renderingMode(.template)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("SearchBar")))
                if (isSearchingTarget == false){
                    LocationInformationFloorArea(location: targetLocation)
                        .onTapGesture {
                            HeaderTap.tap()
                        }
                }
            }
        }
        
        //Find destination text field
       @ViewBuilder
        var findDestinationTextField: some View {
            TextField("Find destination", text: $targetSearchText)
                .valueChanged(value: targetSearchText) { _ in
                    MapsIndoorsSearch.locationsFromQuery(searchText: targetSearchText, nearPosition: nil) { locations in
                        targetSearchResult = locations
                        if let userLocation = myLocation {
                            targetSearchResult.insert(userLocation, at: 0)
                        }
                    }
                }
        }
        
    }
    
    struct UtilityBar: View {
        @Binding var sourceSearchText: String
        @Binding var targetSearchText: String
        
        @Binding var sourceLocation:MPLocation?
        @Binding var targetLocation:MPLocation?
        
        @ObservedObject var state: MapsIndoorsMapState
        
        var body: some View {
            HStack {
                reverseButton
                Spacer()
                // iOS really wants the toggle to use the full width of the view, so we create or own label and hide the one created from the toggle
                Text("Accessibility")
                Toggle("Accessibility", isOn: $state.routeAccessibility)
                    .toggleStyle(.switch)
                    .frame(alignment: .trailing)
                    .labelsHidden()
            }.padding(.horizontal)
        }
        
        // Reverse button
        var reverseButton: some View {
            Button(action: reverse){
                Image("Reverse")
                    .renderingMode(.template)
                    .foregroundColor(Color("ButtonColor"))
                Text("Reverse")
                    .foregroundColor(Color("ButtonColor"))
            }
        }
        
        func reverse(){
            var holderLocation: MPLocation?


            holderLocation = sourceLocation

            sourceLocation = targetLocation
            sourceSearchText = sourceLocation?.name ?? ""

            targetLocation = holderLocation
            targetSearchText = targetLocation?.name ?? ""
        }
    }
    
    struct ResultList: View {
        @Binding var searchText: String
        @Binding var resultList: [MPLocation]
        @Binding var myLocation: MPLocation?
        static var selection = PassthroughSubject<MPLocation, Never>()

        var body: some View {
            if (searchText == "") {
                EmptyList(myPosition: $myLocation)
            }
            else if (resultList.isEmpty){
                ZStack (alignment: .top){
                    List(){
                        
                    }
                    Text("No Results")
                        .font(.title)
                        .frame(alignment: .center)
                        .padding()
                }
            } else {
                List(resultList, id:\.locationId) { location in
                    LocationResult(location: location)
                        .onTapGesture {
                            DirectionsView.ResultList.selectLocation(location: location)
                        }
                }
            }
        }
        
        static func selectLocation(location: MPLocation){
            selection.send(location)
        }
    }
    
    struct GetDirectionsButton: View {
        @Binding var sourceLocation: MPLocation?
        @Binding var targetLocation: MPLocation?
        @ObservedObject var state: MapsIndoorsMapState
        
        static var approved = PassthroughSubject<Bool, Never>()
        
        var body: some View {
            if (sourceLocation == nil || targetLocation == nil) {
                placeholderStartDirectionsButton
            } else {
                startDirectionsButton
            }
        }
        
        // Start directions button - if target location not found
        var placeholderStartDirectionsButton: some View {
            Button(action: doNothing){
                Text("Start")
                    .font(.system(size: 16))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
                    .padding()
            }
        }
        
        // Start directions button - if target location is found
        var startDirectionsButton: some View {
            Button(action: DirectionsView.GetDirectionsButton.confirmSelections){
                BlueButton(labelText: "Start")
            }
        }
        
        static func confirmSelections(){
            approved.send(true)
            
        }
        
        func doNothing(){
            
        }
    }
}

struct HeaderDirectionsView: View {
    @Binding var bottomSheetPosition: CustomBottomSheetPosition
    @Binding var gettingDirections: Bool
    
    var body: some View {
        HStack {
            getDirectionsLabel
            Spacer()
            closeDirectionsButton
        }.contentShape(Rectangle())
            .onTapGesture {
                HeaderTap.tap()
                
            }
    }
    
    // Get directions label
    var getDirectionsLabel: some View {
        VStack(alignment: .leading) {
            Text("Get directions")
                .font(.title).bold()
            Divider()
                .padding(.trailing)
        }
    }
    
    // close directions button
    var closeDirectionsButton: some View {
        Button(action: closeDirectionsView){
            CloseButton()
        }.padding(.bottom)
    }
    
    func closeDirectionsView(){
        bottomSheetPosition = .bottom
        gettingDirections = false
    }
}

struct HeaderTap {
    static var didTap = PassthroughSubject<Bool, Never>()
    
    static func tap(){
        didTap.send(true)
    }
}

