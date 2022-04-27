//
//  KeyboardServices.swift
//  MapsIndoors Template - IOS
//
//  Created by Shahab Shajarat on 29/11/2021.
//

import Foundation
import UIKit

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
