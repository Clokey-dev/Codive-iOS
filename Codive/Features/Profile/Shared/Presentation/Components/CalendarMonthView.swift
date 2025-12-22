//
//  CalendarMonthView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

struct CalendarMonthView: View {
    @Binding var month: Date
    @Binding var selectedDate: Date?

    private let calendar = Calendar.current
    private let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // 이니셜라이저 추가 (public access를 위함)
    init(month: Binding<Date>, selectedDate: Binding<Date?>) {
        self._month = month
        self._selectedDate = selectedDate
    }

    var body: some View {
        VStack(spacing: 10) {
            header
            weekdaysRow
            grid
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    month = calendar.date(byAdding: .month, value: -1, to: month) ?? month
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.Codive.grayscale3)
            }

            Spacer(minLength: 0)

            Text(monthTitle(month))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.Codive.grayscale1)

            Spacer(minLength: 0)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    month = calendar.date(byAdding: .month, value: 1, to: month) ?? month
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.Codive.grayscale3)
            }
        }
        .padding(.bottom, 4)
    }

    private var weekdaysRow: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { w in
                Text(w)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.Codive.grayscale4)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        let days = makeDaysForMonth(month)

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 10) {
            ForEach(days.indices, id: \.self) { idx in
                let item = days[idx]
                dayCell(item)
            }
        }
        .padding(.top, 2)
    }

    private let dayCellHeight: CGFloat = 54
    private let dayNumberSize: CGFloat = 28

    private func dayCell(_ item: CalendarDayItem) -> some View {
        ZStack {
            if item.isPlaceholder {
                Color.clear
                    .frame(height: dayCellHeight)
            } else {
                let isSelected = isSameDay(item.date, selectedDate)
                Color.clear

                Text("\(item.dayNumber)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.Codive.grayscale3)
                    .frame(width: dayNumberSize, height: dayNumberSize)
                    .background {
                        if isSelected {
                            Circle().fill(Color.Codive.point1)
                        } else {
                            Circle().fill(Color.clear)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: dayCellHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            if !item.isPlaceholder {
                selectedDate = item.date
            }
        }
    }

    private func monthTitle(_ date: Date) -> String {
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        return "\(y)년 \(m)월"
    }

    private func isSameDay(_ a: Date?, _ b: Date?) -> Bool {
        guard let a, let b else { return false }
        return calendar.isDate(a, inSameDayAs: b)
    }

    private func makeDaysForMonth(_ date: Date) -> [CalendarDayItem] {
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) // 1=Sun
        let leadingBlanks = max(0, firstWeekday - 1)

        var result: [CalendarDayItem] = []
        result.append(contentsOf: Array(repeating: CalendarDayItem.placeholder, count: leadingBlanks))

        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                result.append(CalendarDayItem(date: d, dayNumber: day, isPlaceholder: false))
            }
        }

        let remainder = result.count % 7
        if remainder != 0 {
            result.append(contentsOf: Array(repeating: CalendarDayItem.placeholder, count: 7 - remainder))
        }

        return result
    }
}

// MARK: - Calendar Models
struct CalendarDayItem: Hashable {
    let date: Date
    let dayNumber: Int
    let isPlaceholder: Bool

    static var placeholder: CalendarDayItem {
        CalendarDayItem(date: Date(), dayNumber: 0, isPlaceholder: true)
    }

    init(date: Date, dayNumber: Int, isPlaceholder: Bool) {
        self.date = date
        self.dayNumber = dayNumber
        self.isPlaceholder = isPlaceholder
    }
}
