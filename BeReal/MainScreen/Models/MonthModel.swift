//
//  MonthModel.swift
//  BeReal
//
//  Created by Vadim Popov on 04.02.2023.
//

import UIKit


class MonthModel {
    
    let month: Int
    let year: Int
    var items: [VideoModel] = []
    let firstWeekDay: Int
    
    static let allMonths = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    
    init(_ month: Int, _ year: Int) {
        self.month = month
        self.year = year
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1
        guard let firstDate = Calendar.current.date(from: dateComponents) else {
            fatalError("Month initializing error")
        }
        
        for i in 1...Date().daysInMonth(month, year) {
            self.items.append(VideoModel(date: firstDate.addingTimeInterval(TimeInterval(i * 3600 * 24))))
        }
        
        let weekday = Calendar.current.component(.weekday, from: firstDate)
        self.firstWeekDay = (weekday != 1) ? weekday : 8
    }
    
    public func getItemIndexWithDate(_ date: Date) -> Int {
        return self.items.firstIndex { item in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            formatter.timeZone = .gmt
            let itemDay = formatter.string(from: item.date)
            let extDay = formatter.string(from: date)
            return itemDay == extDay
        } ?? -1
    }
    
}

extension Date {
    
    func daysInMonth(_ month: Int? = nil, _ year: Int? = nil) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year ?? Calendar.current.component(.year,  from: self)
        dateComponents.month = month ?? Calendar.current.component(.month,  from: self)
        if let d = Calendar.current.date(from: dateComponents),
           let interval = Calendar.current.dateInterval(of: .month, for: d),
           let days = Calendar.current.dateComponents([.day], from: interval.start, to: interval.end).day
        { return days } else { return -1 }
    }

}
