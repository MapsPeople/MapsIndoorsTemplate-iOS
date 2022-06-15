//
//  LocationResult.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 17/11/2021.
//

import SwiftUI
import MapsIndoors

// This view determines how the locations should appear in lists
struct LocationResult: View {
    var location: MPLocation
    
    var body: some View {
        VStack (alignment: .leading){
            HStack (alignment: .top){
                locationIcon
                Spacer()
                locationCell
            }.padding(.trailing)
                .contentShape(Rectangle())
        }
    }
    
    //Location Icon
    var locationIcon: some View {
        var imageName = "Location"

        if location.type == "my-location" {
            imageName = "Mylocation"
        }
        return Image(imageName)
            .renderingMode(.template)
            .foregroundColor(Color(UIColor.systemOrange))
    }
    
    //The cell containing text views
    var locationCell: some View {
        VStack (alignment: .leading){
            
            locationNameLabel
            
            if (location.getField(forKey: "area name")?.value != nil) {
                areaNameLabel
            }
            if (location.floorName != nil && location.floorName != ""){
                floorNumberLabel
            }
        }
    }
    
    // Name Label
    var locationNameLabel: some View {
        HStack {
            Text(location.name ?? "")
                .font(.headline)
            Spacer()
        }
    }
    
    // Area Label
    var areaNameLabel: some View {
        Text(location.getField(forKey: "area name")?.value ?? "")
            .font(.subheadline)
    }
    
    // Floor Number Label
    var floorNumberLabel: some View {
        HStack{
            Text("Floor:")
                .font(.subheadline)
            Text(location.floorName ?? "")
                .font(.subheadline)
        }
    }
    
    
    // Get the categories in a presentable manner
    func getCategories () -> String {
        var categoryList = location.categories?.allValues.description ?? ""
        if (categoryList.count >= 2 && categoryList != ""){
            categoryList.removeLast()
            categoryList.removeFirst()
        }
        
        return categoryList
    }
}
