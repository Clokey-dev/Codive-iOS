//
//  CustomSearchBar.swift
//  Codive
//
//  Created by 한금준 on 10/4/25.
//

import SwiftUI

enum SearchBarType {
    case normal
    case withBackButton(onBack: () -> Void)
}

struct CustomSearchBar: View {
    @Binding var text: String
    var type: SearchBarType = .normal
    
    var body: some View {
        HStack {
            switch type {
            case .withBackButton(let onBack):
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.Codive.main1)
                }
            case .normal:
                EmptyView()
            }

            HStack {
                TextField("찾고싶은 옷이나 브랜드를 검색해보세요", text: $text)
                    .font(Font.codive_body2_medium)
                    .foregroundColor(Color.Codive.grayscale3)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.Codive.main1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.Codive.grayscale7)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct StatefulPreviewWrapper<Value>: View {
    @State private var value: Value
    private var content: (Binding<Value>) -> AnyView

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> some View) {
        _value = State(initialValue: initialValue)
        self.content = { binding in AnyView(content(binding)) }
    }

    var body: some View {
        content($value)
    }
}

#Preview {
    VStack(spacing: 16) {
        // 일반 타입
        StatefulPreviewWrapper("") {
            CustomSearchBar(text: $0, type: .normal)
        }

        // 뒤로가기 버튼 타입
        StatefulPreviewWrapper("") {
            CustomSearchBar(
                text: $0,
                type: .withBackButton {
                    print("뒤로가기 버튼 눌림")
                }
            )
        }
    }
    .padding(.horizontal, 20)
}
