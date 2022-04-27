//
//  DirectionGuideLeg.swift
//  MapsIndoors Template - IOS
//
//  Created by Christian Wolf Johannsen on 25/11/2021.
//

import SwiftUI
import MapsIndoors

struct DirectionGuideLeg: View {
    @State var legInstructions: LegInstructions?
    var errorFindingRoute: Error?
    
    @ViewBuilder
    var body: some View {
        if let instructions = legInstructions {
            VStack {
                HStack {
                    Image("Walk")
                        .renderingMode(.template)
                    Text("Walk")
                    Spacer()
                    Text("\(instructions.distanceDescription) - \(instructions.durationDescription)")
                }
                Divider()
                HStack {
                    instructions.icon
                        .renderingMode(.template)
                    Text(instructions.description)
                }
            }.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        } else if errorFindingRoute == nil {
            calculatingRoute
        }
        else {
            errorWithRoute
        }
    }
    
    var calculatingRoute: some View {
        EmptyView()
    }

    var errorWithRoute: some View {
        Text("Could not find a route…")
    }
}
