//
//  LocationInformation.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 02/12/2021.
//

import SwiftUI
import MapsIndoors

struct LocationInformationFloorArea: View {
    var location:MPLocation?
    
    var body: some View {
        let floor:String = location?.floorName ?? ""
        let area:String = location?.getField(forKey: "area name")?.value ?? ""
        HStack {
            if (floor != ""){
                Text("Floor:")
                Text(floor)
            }
            if (floor != "" && area != ""){
                Text("-")                
            }
            if (area != "") {
                Text(area)
            }
            Spacer()
        }.padding(.horizontal)
            .font(.subheadline)
            .foregroundColor(Color.gray)
    }
}
