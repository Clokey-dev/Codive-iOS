//
//  CompletePopUp.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

import SwiftUI

struct CompletePopUp: View {
    /// 팝업 표시 여부를 제어하는 바인딩
    @Binding var isPresented: Bool

    /// 기록하기 버튼 액션
    var onRecordTapped: () -> Void
    /// 닫기 버튼 액션
    var onCloseTapped: () -> Void
    /// 코디 이미지 URL
    var imageURL: String?

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack {
                Spacer(minLength: 32)

                popupCard
                    .padding(.horizontal, 32)
                    .aspectRatio(311 / 360, contentMode: .fit)

                Spacer(minLength: 32)
            }
        }
    }

    private var popupCard: some View {
        VStack(spacing: 6) {
            Text(TextLiteral.Home.popUpTitle)
                .font(.codive_title1)
                .foregroundColor(Color.Codive.grayscale1)
                .padding(.top, 32)

            Text(TextLiteral.Home.popUpSubtitle)
                .font(.codive_body2_regular)
                .foregroundColor(Color.Codive.grayscale3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 204, height: 204)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 204, height: 204)
                        .clipped()

                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.gray.opacity(0.4))
                        .frame(width: 204, height: 204)
                        .clipped()

                @unknown default:
                    EmptyView()
                }
            }
            .padding(.vertical, 16)

            HStack(spacing: 9) {
                CustomButton(
                    text: TextLiteral.Home.close,
                    widthType: .half,
                    styleType: .border
                ) {
                    isPresented = false
                    onCloseTapped()
                }

                CustomButton(
                    text: TextLiteral.Home.record,
                    widthType: .half
                ) {
                    onRecordTapped()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }
}

#Preview {
    CompletePopUp(
        isPresented: .constant(true),
        onRecordTapped: {},
        onCloseTapped: {},
        imageURL: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800"
    )
}
