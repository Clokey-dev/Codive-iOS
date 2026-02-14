//
//  Date+Format.swift
//  Codive
//

import Foundation

extension Date {
    /// "yyyy-MM-dd" 형식 문자열로 변환
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
