//
//  SearchView.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 17/11/2021.
//

import SwiftUI
import BottomSheetSwiftUI
import MapsIndoors

// View after the search bar has been unfolded
struct SearchView: View {
    @Binding var searchText:String
    @Binding var bottomSheetPosition: CustomBottomSheetPosition
    @Binding var searchResult: [MPLocation]
    @ObservedObject var state: MapsIndoorsMapState
    
    var body: some View {
        if (searchText != "") {
            if (searchResult.isEmpty) {
                noResultsLabel
            } else if (bottomSheetPosition.rawValue >= CustomBottomSheetPosition.bottom.rawValue) {
                resultsList
            }
        } else {
            EmptyList()
        }
    }
    
    // No results label
    var noResultsLabel: some View {
        Text("No Results")
            .font(.title)
            .frame(alignment: .center)
    }
    
    // Search results list
    var resultsList: some View {
        List(searchResult, id:\.locationId) { location in
            LocationResult(location: location).onTapGesture {
                state.mapControl?.selectedLocation = location
                state.adjustZoom = true
                state.mapControl?.go(to: location)
                dismissKeyboard()
            }
        }
    }
}

struct HeaderSearchView: View {
    @Binding var searchText: String
    @Binding var bottomSheetPosition: CustomBottomSheetPosition
    @Binding var searchResult: [MPLocation]
    @ObservedObject var mapState: MapsIndoorsMapState
    @State private var position: MPPoint = MPPoint.init()
    
    var body: some View {
        VStack {
            HStack {
                searchBar
                if (bottomSheetPosition.rawValue > CustomBottomSheetPosition.bottom.rawValue) {
                    showSearchResultsButton
                }
            }
            Divider()
                .padding(.trailing)
        }
        .onAppear(perform: {
            bottomSheetPosition = .bottom
        })
        .onDisappear {
            resetMapFilter()
        }
    }
    
    
    // SearchBar and search results
    var searchBar: some View {
        HStack { // Create the SearchBar and prepare the the search results when the user types
            SearchBarWithSymbol(placeHolder: "Search...", searchText: $searchText).valueChanged(value: searchText) {_ in
                searchText == "" ? resetMapFilter() : updateSearchResult()
            }.onTapGesture {
                self.bottomSheetPosition = .top
                position = MPPoint.init(lat: mapState.mapView?.camera.target.latitude ?? 0, lon: mapState.mapView?.camera.target.longitude ?? 0, zValue: mapState.mapControl?.currentFloor?.doubleValue ?? 0)
                // Below line ensures the search result is always using the latest camera position (even if the search was made prior to moving the camera)
                //  updateSearchResult()
                MapsIndoorsSearch.removeViewingAngle(state: mapState)
            }
        }
    }
    
    //Show search results
    var showSearchResultsButton: some View {
        Button(action: closeSearchView){
            Text("Show")
                .foregroundColor(Color("ButtonColor"))
        }
    }
    
    func resetMapFilter(){
        mapState.mapControl?.searchResult = nil
        mapState.mapControl?.showSearchResult(false)
    }
    
    func updateSearchResult(){
        MapsIndoorsSearch.locationsFromQuery(searchText: searchText, nearPosition: position) { locations in
            searchResult = locations
        }
        mapState.mapControl?.searchResult = searchResult
        mapState.mapControl?.showSearchResult(false)
    }
    
    func closeSearchView(){
        bottomSheetPosition = .bottom
        dismissKeyboard()
    }
}
