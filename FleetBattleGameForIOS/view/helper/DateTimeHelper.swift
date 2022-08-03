//
//  DateTimeHelper.swift
//  FleetBattleGame
//
//  Created by FMA2 on 16.12.21.
//  Copyright © 2021 FMA2. All rights reserved.
//

import Foundation

class DateTimeHelper {
    static func getCurrentDateAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.string(from: Date())
    }
    
    static func getFormattedDateAsString(dateString: String) -> String {
        let date = getDateFromString(dateString: dateString)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter.string(from: date) + " Uhr" 
    }
    
    static func getDateFromString(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter.date(from: dateString) ?? Date()
    }
}
