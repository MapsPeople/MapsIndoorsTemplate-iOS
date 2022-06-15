//
//  EmptyList.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 02/12/2021.
//

import SwiftUI
import MapsIndoors

struct EmptyList: View {
    @Binding var myPosition: MPLocation?
    var helpText: String?
    
    init(myPosition: Binding<MPLocation?>? = nil) {
        self._myPosition = myPosition ?? Binding.constant(nil)
    }
    
    var body: some View {
        VStack {
            if let userPosition = myPosition {
                List() {
                    LocationResult(location: userPosition)
                        .onTapGesture {
                            DirectionsView.ResultList.selectLocation(location: userPosition)
                        }
                }
            } else {
                Text(helpText ?? "Search for locations")
                    .font(.headline)
                    .frame(alignment: .center)
                    .padding()
            }
        }
    }
}
