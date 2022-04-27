//
//  CloseButton.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 19/11/2021.
//

import SwiftUI

struct CloseButton: View {
    var body: some View {
        Image("clear")
            .renderingMode(.template)
            .resizable()
            .frame(width: 35, height: 35)
            .foregroundColor(Color(UIColor.secondaryLabel))
    }
}
