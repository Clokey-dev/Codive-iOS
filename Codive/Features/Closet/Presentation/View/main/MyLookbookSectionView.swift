//
//  MyLookbookSectionView.swift
//  Codive
//
//  Created by 황상환 on 12/15/25.
//

import SwiftUI

struct MyLookbookSectionView: View {
    
    @StateObject private var viewModel: MyLookbookSectionViewModel
    
    init(viewModel: MyLookbookSectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Properties
    
    // 그리드 레이아웃 설정
    let columns = [
        GridItem(.flexible(), spacing: 15, alignment: .top),
        GridItem(.flexible(), spacing: 15, alignment: .top)
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("내 룩북")
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                
                Spacer()
                
                Button(
                    action: { viewModel.navigateToLookBook() },
                    label: {
                        HStack(spacing: 2) {
                            Text("더보기")
                            Image(systemName: "chevron.right")
                        }
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color.Codive.grayscale2)
                    }
                )
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: columns, spacing: 20) {
                if viewModel.lookBookList.count < 4 {
                    AddLookbookButton {
                        print("룩북 만들기 클릭")
                        viewModel.navigateToAddLookbook()
                    }
                }

                let displayCount = viewModel.lookBookList.count < 4 ? 3 : 4
                
                ForEach(viewModel.lookBookList.prefix(displayCount)) { item in
                    LookbookCardView(item: item) { selectedItem in
                        viewModel.navigateToSpecificLookbook(lookBook: selectedItem)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .onAppear {
            viewModel.fetchMyLookBooks()
        }
    }
}

// MARK: - AddLookbookButton
struct AddLookbookButton: View {
    
    // MARK: - Properties
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.Codive.main2)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "plus")
                        .font(.codive_title3)
                        .foregroundStyle(.white)
                }
                
                Text("룩북 만들기")
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.Codive.grayscale5)
            )
            .cornerRadius(12)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

// MARK: - LookbookCardView
struct LookbookCardView: View {
    
    // MARK: - Properties
    let item: LookBookEntity
    let onTap: (LookBookEntity) -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                // 배경색
                Rectangle()
                    .fill(Color.Codive.grayscale6)

                AsyncImage(url: URL(string: item.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "tshirt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundStyle(Color.Codive.grayscale4)
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.Codive.grayscale5, lineWidth: 1)
            )
 
            Text(item.lookbookName)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
                .lineLimit(1)
                .padding(.leading, 2)
        }
        .onTapGesture {
            onTap(item)
        }
    }
}
