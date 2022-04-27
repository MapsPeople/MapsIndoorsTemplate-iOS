//
//  BlueButton.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 19/11/2021.
//

import SwiftUI

struct BlueButton: View {
    var labelText: String
    var darkMode: Int =  UIUserInterfaceStyle.RawValue.init()

    var body: some View {
        Text(labelText)
            .font(.system(size: 16))
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color("ButtonColor"))
            .foregroundColor(Color.white)
            .cornerRadius(20)
            .padding()
    }
}
