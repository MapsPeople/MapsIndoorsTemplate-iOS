//
//  DetailView.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 17/11/2021.
//

import SwiftUI
import UIKit
import BottomSheetSwiftUI

// Show this view after a location has been selected (either through the map or the searchview)
struct DetailView: View {
    @State var showingMore:Bool = false
    @Binding var bottomSheetPosition: CustomBottomSheetPosition
    @ObservedObject var state: MapsIndoorsMapState
    @Binding var gettingDirections: Bool
    var lineSpacing:CGFloat = 4
    @State var linelimit:Int? = 3
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    @State private var isTruncated: Bool = true
    
    var body: some View {
        let description = state.mapControl?.selectedLocation?.descr ?? ""
        let categories = getCategories()
        
        VStack(alignment: .leading) {
            if (categories != "") {
                HStack() {
                    Image("Category")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.systemGreen))
                    Text(categories)
                        .lineSpacing(lineSpacing)
                    Spacer()
                }
            }
                
            if (description != "" ) {
                HStack(alignment: .top) {
                    Image("Description")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.systemOrange))
                    VStack (alignment: .leading){
                        // How much of the description should be shown
                            Text(description)
                                .lineSpacing(lineSpacing)
                                .lineLimit(linelimit)
                                .readSize { size in
                                    truncatedSize = size
                                    isTruncatedUpdate(value: truncatedSize != intrinsicSize)
                                }
                                .background(
                                Text(description)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .hidden()
                                    .readSize(onChange: { size in
                                        intrinsicSize = size
                                        isTruncatedUpdate(value: truncatedSize != intrinsicSize)
                                    })
                                )
                        if (isTruncated) {
                        Button(action: showingMore ? showLess : showMore) {
                            showingMore ?
                            Text("Show less")
                                .foregroundColor(Color("ButtonColor"))
                            :
                            Text("Show more")
                                .foregroundColor(Color("ButtonColor"))
                        }
                    }
                }
            }
            }
            Spacer()
            Button(action: getDirectionView){
                BlueButton(labelText: "Get directions")
            }
        }.padding()
            .onAppear(){
                bottomSheetPosition = .middle
            }
            .valueChanged(value: bottomSheetPosition) { _ in
                if (bottomSheetPosition.rawValue > CustomBottomSheetPosition.middle.rawValue){
                    showMore()
                } else {
                    showLess()
                }
            }
    }
    
    // Get the Category list in a readable manner
    func getCategories () -> String {
        var categoryList = state.mapControl?.selectedLocation?.categories?.allValues.description ?? ""
        if (categoryList.count >= 2 && categoryList != ""){
            categoryList.removeLast()
            categoryList.removeFirst()
        }
        
        return categoryList
    }
    
    func isTruncatedUpdate (value: Bool) {
        if (truncatedSize.height > intrinsicSize.height && showingMore == false){
            isTruncated = false
        } else {
            isTruncated = value
        }
    }
    
    func getDirectionView(){
        gettingDirections = true
        
    }
    
    func showMore(){
        bottomSheetPosition = .top
        showingMore = true
        linelimit = nil
    }
    
    func showLess(){
        bottomSheetPosition = .middle
        showingMore = false
        linelimit = 3
    }
}

struct HeaderDetailView: View {
    @Binding var bottomSheetPosition: CustomBottomSheetPosition
    @ObservedObject var state:MapsIndoorsMapState
    
    var body: some View {
        let floorName = state.mapControl?.selectedLocation?.floorName
        let locationName = state.mapControl?.selectedLocation?.name
        let buildingName = state.focusedBuilding?.name
        let venueName = state.selectedVenue?.name
        
        HStack {
            VStack(alignment: .leading) {
                HStack { // Show the Floornumber then the location name
                    if (floorName != nil && floorName != ""){
                        HStack(spacing: 0.2){
                            Image("Floor")
                                .renderingMode(.template)
                                .foregroundColor(Color("ButtonColor"))
                            Text(floorName ?? "")
                        }
                    }
                    Text(locationName ?? buildingName ?? venueName ?? "")
                        .font(.title)
                }
                Divider()
                    .padding(.trailing)
            }.onAppear{
                bottomSheetPosition = .middle
            }
            Button(action: closeDetailsView){
                CloseButton()
            }.padding(.bottom)
        }
    }
    
    func closeDetailsView(){
        state.mapControl?.selectedLocation = nil
        bottomSheetPosition = .bottom
    }
}
