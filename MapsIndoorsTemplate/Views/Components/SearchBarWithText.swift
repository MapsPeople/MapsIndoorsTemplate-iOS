//
//  SearchBarWithText.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 29/11/2021.
//

import SwiftUI

struct SearchBarWithText: View {
    var text: String
    var placeHolder:String
    @Binding var searchText:String
    
    var body: some View {
        HStack {
            Text(text)
            TextField(placeHolder, text: $searchText)
            
            if (searchText != ""){
                Button(action: {
                    self.searchText = ""
                }) {
                    Image("clear")
                        .renderingMode(.template)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color("SearchBar")))
    }
}
