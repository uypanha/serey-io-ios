//
//  Date+Formatter.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/28/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

extension Date {
    
    func format(_ format: String, timeZone: String? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let zone = timeZone {
            dateFormatter.timeZone = TimeZone(abbreviation: zone)
        }
        let timeStamp = dateFormatter.string(from: self)
        
        return "\(timeStamp)"
    }
    
    static func date(from: String?, format: String) -> Date? {
        if let dateString = from {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            
            return dateFormatter.date(from:dateString)
        }
        
        return nil
    }
    
    func roundUp() -> Date {
        return Date.date(from: self.format("yyyy-MM-dd"), format: "yyyy-MM-dd")!
    }
}

// MARK: -
extension Date {
    
    // Returns the number of years
    func yearsCount(to date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: self.roundUp(), to: date.roundUp()).year ?? 0
    }
    
    // Returns the number of months
    func monthsCount(to date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: self.roundUp(), to: date.roundUp()).month ?? 0
    }
    
    // Returns the number of weeks
    func weeksCount(to date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: self.roundUp(), to: date.roundUp()).weekOfMonth ?? 0
    }
    
    // Returns the number of days
    func daysCount(to date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: self), to: calendar.startOfDay(for: date)).day ?? 0
    }
    
    // Returns the number of hours
    func hoursCount(to date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: self, to: date).hour ?? 0
    }
    
    // Returns the number of minutes
    func minutesCount(to date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: date).minute ?? 0
    }
    
    // Returns the number of seconds
    func secondsCount(to date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: self, to: date).second ?? 0
    }
    
    // Returns time ago by checking if the time differences between two dates are in year or months or weeks or days or hours or minutes or seconds
    func timeAgo(to date: Date, numericDates: Bool = true) -> String {
        let yearsCount = self.yearsCount(to: date)
        if yearsCount > 0 {
            if numericDates || yearsCount > 1 {
                return "\(yearsCount) year\(yearsCount > 1 ? "s" : "") ago"
            }
            return "Last year"
        }
        let monthsCount = self.monthsCount(to: date)
        if monthsCount > 0 {
            if (numericDates || monthsCount > 1) {
                return "\(monthsCount) month\(monthsCount > 1 ? "s" : "") ago"
            }
            
            return "Last month"
        }
        let weeksCount = self.weeksCount(to: date)
        if weeksCount > 0 {
            if (numericDates || weeksCount > 1) {
                return "\(weeksCount) week\(weeksCount > 1 ? "s" : "") ago"
            }
            return "Last week"
        }
        let daysCount = self.daysCount(to: date)
        if daysCount > 0 {
            if (numericDates || daysCount > 1) {
                return "\(daysCount) day\(daysCount > 1 ? "s" : "") ago"
            }
            
            return "Yesterday"
        }
        let hoursCount = self.hoursCount(to: date)
        if hoursCount > 0 {
            if (numericDates || hoursCount > 1) {
                return "\(hoursCount) hour\(hoursCount > 1 ? "s" : "") ago"
            }
            return "An hour ago"
        }
        let minutesCount = self.minutesCount(to: date)
        if minutesCount > 0 {
            if (numericDates || minutesCount > 1) {
                return "\(minutesCount) minute\(minutesCount > 1 ? "s" : "") ago"
            }
            return "a minute ago"
        }
        let secondsCount = self.secondsCount(to: date)
        if secondsCount >= 3 {
            return "\(secondsCount) seconds ago"
        }
        return "Just now"
    }
    
    func timeCount(to date: Date) -> String {
        let yearsCount = self.yearsCount(to: date)
        if yearsCount > 0 {
            return "\(yearsCount)y"
        }
        let weeksCount = self.weeksCount(to: date)
        if weeksCount > 0 {
            return "\(weeksCount)w"
        }
        let daysCount = self.daysCount(to: date)
        if daysCount > 0 {
            return "\(daysCount)d"
        }
        let hoursCount = self.hoursCount(to: date)
        if hoursCount > 0 {
            return "\(hoursCount)h"
        }
        let minutesCount = self.minutesCount(to: date)
        if minutesCount > 0 {
            return "\(minutesCount)m"
        }
        let secondsCount = self.secondsCount(to: date)
        if secondsCount >= 3 {
            return "\(secondsCount)s"
        }
        return "just now"
    }
}
