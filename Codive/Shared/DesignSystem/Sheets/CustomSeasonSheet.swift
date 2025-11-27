//
//  CustomSeasonSheet.swift
//  Codive
//
//  Created by 한태빈 on 10/6/25.
//

import SwiftUI

struct CustomSeasonSheet: View {
    @State private var selected: Set<Season> = []

    var onClose: () -> Void = {}
    var onApply: (_ selected: Set<Season>) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 타이틀 + 닫기
            Text("계절 필터")
                .font(.codive_title2)
                .foregroundStyle(Color("Grayscale1"))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
                .overlay(alignment: .trailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color("main1"))
                            .frame(width: 18, height: 18)
                    }
                    .padding(.trailing, 16)
                }

            // 항목 리스트
            VStack(spacing: 0) {
                ForEach(Season.allCases) { season in
                    let isSelected = selected.contains(season)

                    Divider()

                    Button {
                        toggle(season)
                    } label: {
                        ZStack {
                            // 선택 시 배경색 변경
                            (isSelected ? Color("Grayscale6") : Color.clear)

                            // 체크마크
                            HStack {
                                
                                Image(systemName: "checkmark")
                                    .foregroundStyle(isSelected ? Color("main0") : Color("main4"))
                                    .frame(width: 20, height: 20)
                                
                                Spacer()
                            }
                            .padding(.leading, 100)
                            // 중앙 텍스트
                            Text(season.rawValue)
                                .font(.codive_title3)
                                .foregroundStyle(Color("Grayscale1"))
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 56)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            // 적용 버튼
            let enabled = !selected.isEmpty
            Button {
                onApply(selected)
            } label: {
                Text("적용하기")
                    .font(.codive_title2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(enabled ? Color("main0") : Color("main4"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(!enabled)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
    }

    // 선택 토글
    private func toggle(_ season: Season) {
        if selected.contains(season) {
            selected.remove(season)
        } else {
            selected.insert(season)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        CustomSeasonSheet(
            onClose: { print("닫기") },
            onApply: { print("적용:", $0.map(\.rawValue)) }
        )
    }
}
