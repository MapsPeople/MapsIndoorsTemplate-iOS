//
//  SearchBar.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 22/11/2021.
//

import SwiftUI

struct SearchBarWithSymbol: View {
    var symbol: String = "Search"
    var placeHolder:String
    @Binding var searchText:String
    
    var body: some View {
        HStack {
            symbol == "Search" ? Image(symbol) : Image(systemName:symbol)
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
