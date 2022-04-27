//
//  MapsIndoorsView.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 17/11/2021.
//

import SwiftUI
import GoogleMaps
import MapsIndoors
import BottomSheetSwiftUI

// Custom bottomsheetpositions, numbers are screen cover percentage
enum CustomBottomSheetPosition: CGFloat, CaseIterable, RawRepresentable {
    case top, middle, middleBottom, bottom, hidden
    
    // Return size percentage based on screen height to accommodate small screens
    // i.e. iPhones with physical touch button (iPhones before iPhone X).
    // The screenSizeBreakpoint has been influenced by information at https://www.ios-resolution.com/
    var rawValue: CGFloat {
        let screenSizeBreakpoint = 800.0
        
        let h = UIScreen.main.bounds.height
        switch self {
        case .middleBottom:
            return h < screenSizeBreakpoint ? 0.4 : 0.3
            
        case .top:
            return 1.0
            
        case .middle:
            return h < screenSizeBreakpoint ? 0.63 : 0.475
            
        case .bottom:
            return h < screenSizeBreakpoint ? 0.15 : 0.075
            
        case .hidden:
            return 0
        }
    }
}

extension Animation {
    static func moveToBottom() -> Animation {
        Animation.linear(duration: 3.5)
            .speed(3)
    }
    
    static func easeOutSplash() -> Animation {
        Animation.easeOut(duration: 1.5)
    }
}

extension AnyTransition {
    static var moveAndFadeBottom: AnyTransition {
        AnyTransition.move(edge: .bottom)
            .combined(with: AnyTransition
                .offset(x: 0, y: UIScreen.main.bounds.size.height * CustomBottomSheetPosition.bottom.rawValue))
    }
    
    
}

struct SplashScreen: View {
    @ObservedObject var state: MapsIndoorsMapState
    @Binding var finishedLoading: Bool
    @State private var deviceSize: CGSize = UIScreen.main.bounds.size
    @State private var done:Bool = false
    @State private var isLoading = false
    @State private var enableLoadingSpinner = false
    
    
    var body: some View {
        ZStack{
            if (done) {
                
            }
            else if (finishedLoading) {
                
                handleFinishLoading
                
            }
            else if (state.didFinishLoading) {
                
                handleDidFinishLoading
                
            } else {
                
                logoAndSpinner
                
            }
        }
    }
    
    var handleFinishLoading: some View {
        VStack {
            Spacer()
            Color(UIColor.systemBackground)
                .frame(height: deviceSize.height * CustomBottomSheetPosition.bottom.rawValue, alignment: .bottom).offset(x: 0, y: 25)
        }.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                withAnimation(.easeOutSplash()){
                    done = true
                }
            }
        }
    }
    
    var handleDidFinishLoading: some View {
        Color(UIColor.systemBackground)
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    withAnimation(.easeOut){
                        withAnimation (.moveToBottom()) {
                            
                            finishedLoading = true
                        }
                    }
                }
            }.transition(.moveAndFadeBottom)
    }
    
    var logoAndSpinner: some View {
        ZStack{
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.bottom)
            VStack(alignment: .center, spacing: -38.0) {
                Text("POWERED BY")
                    .font(.headline)
                Image("logo")
                    .scaleEffect(0.9)
                    .padding(.bottom, 100)
                if(enableLoadingSpinner){
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.green, lineWidth: 5)
                        .frame(width: 50, height: 50)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.default.repeatForever(autoreverses: false).speed(0.4))
                        .onAppear {
                            self.isLoading = true
                        }
                }
            }.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    enableLoadingSpinner.toggle()
                }
            }
        }
    }
}

struct MapsIndoorsView: View {
    @State var finishedLoading: Bool = false
    @State private var searchText: String = ""
    @State private var bottomSheetPosition: CustomBottomSheetPosition = .bottom
    @State private var locationSelected: Bool = false
    //selectedLocation is utilizing the locationModel
    @State private var selectedLocation: Location?
    @State private var gettingDirections: Bool = false
    @State private var showingDirections: Bool = false
    @State private var isSearching: Bool = false
    @State private var searchResult: [MPLocation] = []
    @ObservedObject var mapState = MapsIndoorsMapState(camera: GMSCameraPosition(), floor: 1)
    
    let resizeableOptions: [BottomSheet.Options] = [.cornerRadius(0), .animation(.linear(duration: 0.1)), .noBottomPosition, .allowContentDrag]
    
    init(activeUserRoles: [String]? = nil) {
        guard let userRoles = activeUserRoles else {
            return
        }
        mapState.applyUserRoles(userRoles)
    }
    
    var body: some View {
        ZStack {
            mapFrame
            SplashScreen(state: mapState, finishedLoading: $finishedLoading)
        }
    }
    
    //Setting the frame and initializes the MapsIndoorsMap with the mapState
    var mapFrame: some View {
        VStack {
            GeometryReader { geometry in
                MapsIndoorsMap( mapState: mapState)
                    .animation(nil)
                    .frame(height: (geometry.frame(in: .global).height) * (1 - bottomSheetPosition.rawValue), alignment: .topLeading)
                Spacer()
            }.valueChanged(value: bottomSheetPosition){ _ in
                // For some reason it is possible to drag the bottomsheet above the top modifier with contentDrag enabled.
                // Ensure the BottomSheet never goes above 100% screen coverage
                if (bottomSheetPosition.rawValue > CustomBottomSheetPosition.top.rawValue){
                    bottomSheetPosition = CustomBottomSheetPosition.top
                }
                if (bottomSheetPosition.rawValue <= CustomBottomSheetPosition.bottom.rawValue){
                    mapState.mapControl?.floorSelectorHidden = false
                    dismissKeyboard()
                } else {
                    if (showingDirections){
                        mapState.mapControl?.floorSelectorHidden = false
                    } else {
                        mapState.mapControl?.floorSelectorHidden = true
                    }
                }
            }
            .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, options: resizeableOptions, headerContent: {
                sheetHeaderContent.animation(nil)
                    .transition(.identity)
            }){
                sheetBodyContent.transition(.identity)
                    .animation(nil)
            }
        }
    }
    
    // Figure out which Header to show on the bottom sheet
    @ViewBuilder
    var sheetHeaderContent: some View {
        if (showingDirections) {
            DirectionsGuideHeaderView(showingDirections: $showingDirections, mapState: mapState)
        } else if (gettingDirections) {
            HeaderDirectionsView(bottomSheetPosition: $bottomSheetPosition, gettingDirections: $gettingDirections)
            // If a location has been selected (either on the map or through the search view)
        } else if (mapState.mapControl?.selectedLocation != nil) {
            HeaderDetailView(bottomSheetPosition: $bottomSheetPosition, state: mapState)
        }  else {
            HeaderSearchView(searchText: $searchText, bottomSheetPosition: $bottomSheetPosition, searchResult: $searchResult, mapState: mapState)
                .onAppear {
                    bottomSheetPosition = .bottom
                }
        }
    }
    
    // Figure out the main content of the bottom sheet
    @ViewBuilder
    var sheetBodyContent: some View {
        if (showingDirections) {
            DirectionsGuideView(mapState: mapState, bottomSheetPosition: $bottomSheetPosition, showingDirections: $showingDirections)
        } else if (gettingDirections) {
            DirectionsView(bottomSheetPosition: $bottomSheetPosition, state: mapState, gettingDirections: $gettingDirections, showingDirections: $showingDirections)
            // If a location has been selected (either on the map or through the search view)
        } else if (mapState.mapControl?.selectedLocation != nil) {
            DetailView(bottomSheetPosition: $bottomSheetPosition, state: mapState, gettingDirections: $gettingDirections)
        } else {
            SearchView(searchText: $searchText, bottomSheetPosition: $bottomSheetPosition, searchResult: $searchResult, state: mapState)
        }
    }
}
