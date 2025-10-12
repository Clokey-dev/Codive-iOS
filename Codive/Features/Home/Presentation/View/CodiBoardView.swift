//
//  CodiBoardView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct CodiBoardView: View {
    var body: some View {
        CustomNavigationBar(title: "코디보드") {
            print("뒤로가기")
        }
        ScrollView {
            VStack {
                Text("옷을 자유롭게 배치해 스타일을 살펴보세요.")
                    .font(Font.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
            }
        }
        Spacer()
    }
}

#Preview {
    CodiBoardView()
}
