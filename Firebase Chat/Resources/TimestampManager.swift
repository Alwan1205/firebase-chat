//
//  TimestampManager.swift
//  Firebase Chat
//
//  Created by Admin on 19/1/22.
//

import UIKit

final class TimestampManager {
    
    static let shared = TimestampManager()
    
    public func getCurrentTimestamp() -> String {
        let currentTimestamp = String(Date().timeIntervalSince1970)
        
        return currentTimestamp
    }
    
    public func convertTimestampToDateString(timestamp: String) -> String? {
        guard let timeInterval = TimeInterval(timestamp)
        else {
            print("timeInterval not found")
            return nil
        }
        
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "EEEE, d MMMM yyyy - HH:mm"
        formatter.locale = Locale(identifier: "id")
        
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    
}
