//
//  EmptyList.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 02/12/2021.
//

import SwiftUI

struct EmptyList: View {
    var helpText:String?
    
    var body: some View {
        ZStack (alignment: .top){
            List(){
                
            }
            Text(helpText ?? "Search for locations")
                .font(.headline)
                .frame(alignment: .center)
                .padding()
        }
    }
}
