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
    let maxLimit: Int = 10

    private var isDefaultCategory: Bool {
        return title == "상의" || title == "바지" || title == "신발"
    }

    private var minCount: Int {
        return isDefaultCategory ? 1 : 0
    }

    var body: some View {
        HStack {
            Text(title)
                .font(Font.codive_body1_medium)
                .foregroundColor(.black)
            
            Spacer()
            
            Button {
                if count > minCount {
                    count -= 1
                }
            } label: {
                Circle()
                    .fill(count > minCount ? Color.Codive.main5 : Color.Codive.grayscale5)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(count > minCount ? Color.Codive.main1 : Color.Codive.grayscale3)
                    )
            }
            .disabled(count <= minCount)
            
            Text("\(count)")
                .font(Font.codive_body1_medium)
                .foregroundColor(.black)
                .frame(width: 24)
            
            Button {
                if totalCount < maxLimit {
                    count += 1
                }
            } label: {
                Circle()
                    .fill(totalCount < maxLimit ? Color.Codive.main5 : Color.Codive.grayscale5)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(totalCount < maxLimit ? Color.Codive.main1 : Color.Codive.grayscale3)
                    )
            }
            .disabled(totalCount >= maxLimit)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 999)
                .stroke(Color.Codive.grayscale5)
        )
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
            totalCount: 1
        )
        .padding()
    }
}
