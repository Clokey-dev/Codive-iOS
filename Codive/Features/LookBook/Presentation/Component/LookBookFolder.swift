//
//  LookBookFolder.swift
//  Codive
//
//  Created by 한금준 on 1/16/26.
//

import SwiftUI

enum LookBookSelectionMode {
    case none
    case check(isSelected: Bool)
}

struct LookBookFolder: View {
    let title: String
    let count: Int
    let imageUrl: String?
    let mode: LookBookSelectionMode
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            ZStack(alignment: .bottomTrailing) {
                HStack(spacing: 9) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11.18, style: .continuous)
                            .fill(Color.Codive.grayscale6)
                            .frame(width: 76, height: 76)

                        if let imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 76, height: 76)
                                        .clipShape(RoundedRectangle(cornerRadius: 11.18))
                                case .failure:
                                    defaultImage
                                @unknown default:
                                    defaultImage
                                }
                            }
                        } else {
                            defaultImage
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale1)

                        Text("\(count)")
                            .font(.codive_body3_medium)
                            .foregroundStyle(Color.Codive.grayscale4)
                    }

                    Spacer()
                }
                .padding(.leading, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(Color.Codive.grayscale5, lineWidth: 1)
                        )
                )

                if case .check(let isSelected) = mode {
                    checkButtonOverlay(isSelected: isSelected)
                        .padding(.trailing, 13)
                        .padding(.bottom, 8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var defaultImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFill()
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 11.18))
    }

    @ViewBuilder
    private func checkButtonOverlay(isSelected: Bool) -> some View {
        Image(isSelected ? "check_on" : "check_off")
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
    }
}

struct LookBookExampleView: View {
    @State private var isSelected = false
    
    var body: some View {
        VStack(spacing: 13) {
            LookBookFolder(
                title: "스페인여행",
                count: 20,
                imageUrl: "https://example.com/spain.jpg",
                mode: .none
            ) {
                print("상세 페이지로 이동")
            }

            LookBookFolder(
                title: "선택용 룩북",
                count: 15,
                imageUrl: nil,
                mode: .check(isSelected: isSelected)
            ) {
                isSelected.toggle()
            }
        }
        .padding(20)
    }
}

#Preview {
    LookBookExampleView()
}
