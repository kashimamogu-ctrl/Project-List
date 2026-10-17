//  Date+Format.swift
//  Project List
import Foundation

extension Date
{
    // 今年なら「9/23」、今年以外なら「2027/9/23」
    var shortDateText: String
    {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)

        if calendar.isDate(self, equalTo: Date(), toGranularity: .year)
        {
            return "\(month)/\(day)"
        }

        let year = calendar.component(.year, from: self)
        return "\(year)/\(month)/\(day)"
    }
}
