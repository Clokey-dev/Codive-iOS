//
//  MyPageMainView.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

struct ProfileView: View {

    // MARK: - Mock
    private let username: String = "kiki01"
    private let displayName: String = "일기러버"
    private let introText: String = "안녕하세요 일기 러버에요"
    private let followerCount: Int = 22
    private let followingCount: Int = 20

    // MARK: - State
    @State private var month: Date = Date()                // 현재 표시 월
    @State private var selectedDate: Date? = Date()        // 선택된 날짜(옵션)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topBar

                profileSection
                    .padding(.top, 32)
                
                Divider()
                    .padding(.top, 24)
                    .foregroundStyle(Color.Codive.grayscale7)

                favoriteCodiSection
                    .padding(.top, 24)

                calendarSection
                    .padding(.top, 40)

                Spacer(minLength: 77)
            }
        }
        .background(Color.white)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 12) {
            Text(username)
                .font(.codive_title1)
                .foregroundStyle(Color.Codive.grayscale1)

            Spacer(minLength: 0)

            Button {
            } label: {
                Image("edit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }

            Button {
            } label: {
                Image("setting")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 27)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Profile
    private var profileSection: some View {
        VStack {
            Image("CustomProfile")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())

            Text(displayName)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.top, 9)

            HStack(spacing: 20) {
                Button {
                    // follower tap
                } label: {
                    HStack(spacing: 6) {
                        Text("팔로워")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                        Text("\(followerCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                }

                Button {
                    // following tap
                } label: {
                    HStack(spacing: 6) {
                        Text("팔로잉")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                        Text("\(followingCount)")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                }
            }
            .padding(.top, 4)

            Text(introText)
                .font(.codive_body2_regular)
                .foregroundStyle(Color.Codive.grayscale4)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Favorite Codi
    private var favoriteCodiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최애 코디")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer(minLength: 0)

                Button {
                    // 더보기
                } label: {
                    HStack(spacing: 6) {
                        Text("더보기")
                            .font(.codive_body2_regular)
                            .foregroundStyle(Color.Codive.grayscale3)
                        Image("go")
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.Codive.grayscale3)
                    }
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<8, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 155, height: 155)
                            .codiveCardShadow()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Calendar
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("캘린더")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.horizontal, 20)

            CalendarMonthView(month: $month, selectedDate: $selectedDate)
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .codiveCardShadow()
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - CalendarMonthView (날짜만)
struct CalendarMonthView: View {
    @Binding var month: Date
    @Binding var selectedDate: Date?

    private let calendar = Calendar.current
    private let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

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

                // 나중에 사진이 들어갈 영역(지금은 비워둠)
                // Image(...) 넣을 땐 이 Color.clear 자리에 깔면 됨
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
private struct CalendarDayItem: Hashable {
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

// MARK: - Shadow + Hex
 extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}

extension View {
    func codiveCardShadow() -> some View {
        shadow(color: Color(hex: "#636363").opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ProfileView()
}
