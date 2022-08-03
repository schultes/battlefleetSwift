//
//  Values.swift
//  FleetBattleGame
//
//  Created by FMA2 on 19.11.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation
import SwiftUI

class Texts {
    static let appName = "Battle Fleet"
}

class ColorValue {
    static let primary_light = "#5b87d5"
    static let primary_normal = "#1f5ba3"
    static let primary_dark = "#003274"
    static let secondary_light = "#db4c39"
    static let secondary_normal = "#a31111"
    static let secondary_dark = "#6d0000"
    static let subtitle = "#d3d3d3"
    static let darkGray = "#565656"
    static let green = "#088A08"
    static let grey = "#808080"
}

extension UIColor {
    public convenience init(hex:String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            
            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }
            var r: CGFloat = 0.0
            var g: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 1.0
            
            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)
            
            if ((cString.count) == 8) {
                r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
                g =  CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
                b = CGFloat((rgbValue & 0x0000FF)) / 255.0
                a = CGFloat((rgbValue & 0xFF000000)  >> 24) / 255.0
            } else if ((cString.count) == 6){
                r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
                g =  CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
                b = CGFloat((rgbValue & 0x0000FF)) / 255.0
                a =  CGFloat(1.0)
            }
            
            self.init(  red: r,
                        green: g,
                        blue: b,
                        alpha: a
            )
    }
}
