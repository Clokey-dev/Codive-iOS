//
//  DataBottomSheet.swift
//  Codive
//
//  Created by 한태빈 on 2025/12/23.
//

import SwiftUI

// 바텀시트에서 사용할 아이템 모델 (나중에 API 생기면 붙일 예정)
struct DataBottomSheetClothItem: Identifiable, Hashable {
    let id: UUID = .init()
    let imageName: String
    let brand: String
    let title: String
}

struct DataBottomSheet: View {

    // MARK: - Inputs
    let dataBottomSheetTitle: String
    let totalCount: Int
    let items: [DataBottomSheetClothItem]

    var onTapItem: (DataBottomSheetClothItem) -> Void = { _ in }

    // MARK: - Layout constants
    private let cornerRadius: CGFloat = 24
    private let handleSize = CGSize(width: 52, height: 4)
    private let gridHorizontalPadding: CGFloat = 0
    private let headerHorizontalPadding: CGFloat = 20
    private let headerTopPadding: CGFloat = 16
    private let headerBottomPadding: CGFloat = 14

    private let columnCount: Int = 3
    private let gridSpacing: CGFloat = 0

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columnCount)
    }

    var body: some View {
        VStack(spacing: 0) {
            handle

            header

            Divider()

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
            Text(dataBottomSheetTitle)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)

            Text("총 \(max(0, totalCount))벌")
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale4)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, headerHorizontalPadding)
        .padding(.top, headerTopPadding)
        .padding(.bottom, headerBottomPadding)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(items) { item in
                    CustomClothCard(
                        imageName: item.imageName,
                        brand: item.brand,
                        title: item.title
                    ) {
                        onTapItem(item)
                    }
                }
            }
            .padding(.horizontal, gridHorizontalPadding)
            .padding(.bottom, 24)
        }
    }
}

extension View {
    func dataBottomSheet(
        isPresented: Binding<Bool>,
        dataBottomSheetTitle: String,
        totalCount: Int,
        items: [DataBottomSheetClothItem],
        onTapItem: @escaping (DataBottomSheetClothItem) -> Void = { _ in }
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            DataBottomSheet(
                dataBottomSheetTitle: dataBottomSheetTitle,
                totalCount: totalCount,
                items: items,
                onTapItem: onTapItem
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .background(Color.clear)
        }
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var show = true

        private let sampleItems: [DataBottomSheetClothItem] = Array(repeating: DataBottomSheetClothItem(
            imageName: "samplecloth",
            brand: "나이키",
            title: "Cable knit cardigan navy..."
        ), count: 11)

        var body: some View {
            Color.gray.opacity(0.15)
                .ignoresSafeArea()
                .dataBottomSheet(
                    isPresented: $show,
                    dataBottomSheetTitle: "맨투맨",
                    totalCount: sampleItems.count,
                    items: sampleItems
                )
        }
    }

    return PreviewHost()
}
