import SwiftUI

struct DuplicateRecordModalView: View {
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 닫기 버튼
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.Codive.grayscale3)
            }
            .padding(16)
            .zIndex(1)

            VStack(spacing: 0) {
                // 아이콘
                Image("warning_point")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.bottom, 20)

                // 텍스트
                VStack(spacing: 8) {
                    Text("오늘은 이미 기록을 추가했어요")
                        .font(.codive_title1)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.bottom, 8)

                    Text("스타일 기록은 하루에 한 번만 가능해요.\n이전 기록을 추가하려면 마이페이지 내\n캘린더에서 추가할 수 있어요!")
                        .font(.codive_body1_regular)
                        .foregroundStyle(Color.Codive.grayscale2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 50)
            .padding(.bottom, 50)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()

        DuplicateRecordModalView {}
            .padding(.horizontal, 55)
    }
}
