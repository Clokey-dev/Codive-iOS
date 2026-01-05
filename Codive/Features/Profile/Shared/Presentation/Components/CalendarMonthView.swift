import SwiftUI

struct CalendarMonthView: View {
    @Binding var month: Date
    @Binding var selectedDate: Date?

    private let calendar = Calendar.current
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    init(month: Binding<Date>, selectedDate: Binding<Date?>) {
        self._month = month
        self._selectedDate = selectedDate
    }
    
    private let cellSpacing: CGFloat = 6

    private let weekdayCellSize: CGFloat = 40
    private let dayCellWidth: CGFloat = 40
    private let dayCellHeight: CGFloat = 76
    private var gridWidth: CGFloat { (weekdayCellSize * 7) + (cellSpacing * 6) }

    var body: some View {
        VStack(spacing: 10) {
            header
            weekdaysRow
            grid
        }
        .frame(width: gridWidth)   // 헤더, 요일, 그리드를 같은 폭으로 고정해서 좌우 정렬 맞춤
    }

    private var header: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    month = calendar.date(byAdding: .month, value: -1, to: month) ?? month
                }
            } label: {
                Image("calendar_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.Codive.main1)
                    .frame(width: weekdayCellSize, height: weekdayCellSize)
            }

            Spacer(minLength: 0)

            Text(monthTitle(month))
                .font(.codive_body1_medium)
                .foregroundStyle(Color.Codive.grayscale1)

            Spacer(minLength: 0)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    month = calendar.date(byAdding: .month, value: 1, to: month) ?? month
                }
            } label: {
                Image("calendar_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.Codive.main1)
                    .frame(width: weekdayCellSize, height: weekdayCellSize) // 요일 셀 폭과 맞춤
            }
        }
        .frame(width: gridWidth, height: weekdayCellSize)
    }

    private var weekdaysRow: some View {
        HStack(spacing: cellSpacing) {
            ForEach(0..<weekdaySymbols.count, id: \.self) { idx in
                let w = weekdaySymbols[idx]
                let isWeekend = (idx == 0 || idx == 6) // 일, 토

                Text(w)
                    .font(.codive_body1_regular)
                    .foregroundStyle(isWeekend ? Color.Codive.grayscale3 : Color.Codive.grayscale1)
                    .frame(width: weekdayCellSize, height: weekdayCellSize)
            }
        }
        .frame(width: gridWidth, height: weekdayCellSize)
    }

    private var grid: some View {
        let days = makeDaysForMonth(month)
        let columns = Array(repeating: GridItem(.fixed(dayCellWidth), spacing: cellSpacing), count: 7)

        return LazyVGrid(columns: columns, spacing: cellSpacing) {
            ForEach(days.indices, id: \.self) { idx in
                dayCell(days[idx])
            }
        }
        .frame(width: gridWidth)
    }

    private func dayCell(_ item: CalendarDayItem) -> some View {
        ZStack {
            if item.isPlaceholder {
                Color.clear
            } else {
                let isSelected = isSameDay(item.date, selectedDate)
                let weekday = calendar.component(.weekday, from: item.date) // 1=일 ... 7=토
                let isWeekend = (weekday == 1 || weekday == 7)

                Text("\(item.dayNumber)")
                    .font(.codive_body2_regular)
                    .foregroundStyle(isSelected ? Color.white : (isWeekend ? Color.Codive.grayscale3 : Color.Codive.grayscale1))
                    .frame(width: dayCellWidth, height: dayCellHeight, alignment: .center) // 가운데 정렬
                    .background {
                        if isSelected {
                            Circle()
                                .fill(Color.Codive.point1)
                                .frame(width: 28, height: 28)
                        }
                    }
            }
        }
        .frame(width: dayCellWidth, height: dayCellHeight)
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
