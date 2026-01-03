//
//  CategoryCounterView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct CategoryCounterView: View {
    let title: String
    @Binding var count: Int

    let totalCount: Int
    let isFixed: Bool
    
    private let maxLimit: Int = 7
    private let categoryLimit: Int = 1
    
    /// Treats count like an empty-state flag for lint clarity
    private var isEmpty: Bool {
        count == .zero
    }

    var body: some View {
        HStack {
            Text(title)
                .font(Font.codive_body1_medium)
                .foregroundStyle(.black)
            
            Spacer()
            
            // 감소 버튼: 이제 상의/하의 등도 isEmpty가 아니면(1이면) 0으로 줄일 수 있습니다.
            Button {
                if !isFixed && !isEmpty {
                    count -= 1
                }
            } label: {
                Circle()
                    .fill(!isFixed && !isEmpty ? Color.Codive.main5 : Color.Codive.grayscale5)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(!isFixed && !isEmpty ? Color.Codive.main1 : Color.Codive.grayscale3)
                    )
            }
            .disabled(isFixed || isEmpty)
            
            Text("\(count)")
                .font(Font.codive_body1_medium)
                .foregroundStyle(.black)
                .frame(width: 24)
            
            // 증가 버튼
            Button {
                if !isFixed && count < categoryLimit && totalCount < maxLimit {
                    count += 1
                }
            } label: {
                Circle()
                    .fill(!isFixed && count < categoryLimit && totalCount < maxLimit ? Color.Codive.main5 : Color.Codive.grayscale5)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(!isFixed && count < categoryLimit && totalCount < maxLimit ? Color.Codive.main1 : Color.Codive.grayscale3)
                    )
            }
            .disabled(isFixed || count >= categoryLimit || totalCount >= maxLimit)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(alignment: .center) {
            RoundedRectangle(cornerRadius: 999)
                .stroke(Color.Codive.grayscale5)
        }
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State var topCount = 1

    var body: some View {
        CategoryCounterView(
            title: "상의",
            count: $topCount,
            totalCount: 1,
            isFixed: true
        )
        .padding()
    }
}
