//
//  TPRandom.swift
//  PluginsForIOSLibrary
//
//  Created by Nicklas Düringer on 13.08.21.
//  Copyright © 2021 FMA1. All rights reserved.
//

import Foundation

/**
Generates a random number or boolean
*/
public class TPRandom {
    
    /**
    Generates a random Integer between the given range
     - Parameter from: Lower bound
     - Parameter to: Upper bound
     - Returns: Integer
    */
    static func int(from: Int, to: Int) -> Int {
        return Int.random(in: from..<to)
    }
    
    /**
    Generates a random Double between the given range
     - Parameter from: Lower bound
     - Parameter to: Upper bound
     - Returns: Double
    */
    static func double(from: Double, to: Double) -> Double {
        return Double.random(in: from..<to)
    }
    
    /**
    Generates a random Boolean
     - Returns: Bool
    */
    static func boolean() -> Bool {
        return Bool.random()
    }
}
