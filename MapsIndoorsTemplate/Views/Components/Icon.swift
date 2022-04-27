//
//  Icon.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 07/01/2022.
//

import SwiftUI

struct Icon: View {
    let iconSearchString: String
    let iconColor: Color
    
    var body: some View {
        Image(iconSearchString)
            .renderingMode(.template)
            .foregroundColor(iconColor)
    }
}

