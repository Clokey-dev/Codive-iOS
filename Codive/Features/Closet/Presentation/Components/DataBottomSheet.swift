//
//  DataBottomSheet.swift
//  Codive
//
//  Created by 한태빈 on 2025/12/23.
//

import SwiftUI
import Kingfisher

struct DataBottomSheet: View {

    // MARK: - Inputs
    let title: String
    let totalCount: Int
    let items: [ClothItem]

    // MARK: - Layout
    private let cornerRadius: CGFloat = 24
    private let handleSize = CGSize(width: 52, height: 4)

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    }

    var body: some View {
        VStack(spacing: 0) {
            handle
            header
            grid
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight]))
    }

    private var handle: some View {
        Capsule()
            .fill(Color.Codive.grayscale5)
            .frame(width: handleSize.width, height: handleSize.height)
            .padding(.top, 10)
            .padding(.bottom, 10)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)

            Text("총 \(max(0, totalCount))벌")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale4)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        KFImage(URL(string: item.imageUrl))
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .background(Color.Codive.grayscale6)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        Text(item.brand)
                            .font(.codive_body3_medium)
                            .foregroundStyle(Color.Codive.grayscale4)
                            .lineLimit(1)

                        Text(item.name)
                            .font(.codive_body3_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - View Modifier

extension View {
    func dataBottomSheet(
        isPresented: Binding<Bool>,
        title: String,
        totalCount: Int,
        items: [ClothItem]
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            DataBottomSheet(
                title: title,
                totalCount: totalCount,
                items: items
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
}
