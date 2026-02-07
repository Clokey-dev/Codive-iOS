import SwiftUI

struct EmptyHistoryModalView: View {
    let selectedDate: Date?
    let onClose: () -> Void
    let onAddRecord: () -> Void

    private var dateString: String {
        guard let date = selectedDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더: 날짜 + 닫기 버튼
            HStack {
                Text(dateString)
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale1)

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.Codive.grayscale3)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Spacer()
                .frame(height: 24)

            // 아이콘
            Image("ic_edit")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.Codive.main0)
                .padding(.bottom, 20)

            // 텍스트
            VStack(spacing: 4) {
                Text("아직 기록이 없어요.")
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color.Codive.grayscale1)

                Text("스타일을 추가해볼까요?")
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .padding(.bottom, 32)

            Spacer()

            // 버튼
            CustomButton(
                text: "스타일 기록하러 가기",
                widthType: .dynamic,
                styleType: .fill,
                action: onAddRecord
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }
}

#Preview {
    EmptyHistoryModalView(
        selectedDate: Date(),
        onClose: {},
        onAddRecord: {}
    )
    .frame(height: 300)
    .background(Color.gray.opacity(0.2))
}
