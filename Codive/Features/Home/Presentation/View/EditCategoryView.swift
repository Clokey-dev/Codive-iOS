//
//  EditCategoryView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct EditCategoryView: View {
    @State private var topCount = 0
    @State private var bottomCount = 0
    @State private var skirtCount = 0
    @State private var outerCount = 0
    @State private var shoeCount = 0
    @State private var bagCount = 0
    @State private var accessoryCount = 0
    
    var totalCount: Int {
        topCount + bottomCount + skirtCount + outerCount + shoeCount + bagCount + accessoryCount
    }
    
    var body: some View {
        CustomNavigationBar(title: "카테고리 편집하기") {
            print("뒤로가기")
        }
        
        ScrollView {
            VStack {
                Text("현재 카테고리(\(totalCount)/10)")
                    .font(Font.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                
                VStack(spacing: 60) {
                    VStack(spacing: 24) {
                        CategoryCounterView(title: "상의", count: $topCount, totalCount: totalCount)
                        CategoryCounterView(title: "바지", count: $bottomCount, totalCount: totalCount)
                        CategoryCounterView(title: "스커트", count: $skirtCount, totalCount: totalCount)
                        CategoryCounterView(title: "아우터", count: $outerCount, totalCount: totalCount)
                        CategoryCounterView(title: "신발", count: $shoeCount, totalCount: totalCount)
                        CategoryCounterView(title: "가방", count: $bagCount, totalCount: totalCount)
                        CategoryCounterView(title: "패션 소품", count: $accessoryCount, totalCount: totalCount)
                    }
                    
                    HStack(spacing: 9) {
                        CustomButton(text: "초기화", widthType: .outlinedHalf) {
                            print("취소 tapped")
                        }
                        CustomButton(text: "적용하기", widthType: .half) {
                            print("확인 tapped")
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        Spacer()
    }
}

#Preview {
    EditCategoryView()
}
