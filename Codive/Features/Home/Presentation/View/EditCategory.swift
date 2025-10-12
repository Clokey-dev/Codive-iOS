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
    
    let range: ClosedRange<Int> = 0...10

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Button {
                if count > range.lowerBound {
                    count -= 1
                }
            } label: {
                Circle()
                    .fill(Color(white: 0.93))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(count > range.lowerBound ? .brown : .gray)
                    )
            }
            .disabled(count <= range.lowerBound)
            
            Text("\(count)")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 24)
            
            Button {
                if totalCount < maxLimit {
                    count += 1
                }
            } label: {
                let isMaxed = totalCount >= maxLimit
                
                Circle()
                    .fill(Color(white: 0.93))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isMaxed ? .gray : .brown)
                    )
            }
            .disabled(totalCount >= maxLimit)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
