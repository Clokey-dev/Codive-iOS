//
//  RecentlySearchResultRow.swift
//  Codive
//
//  Created by 한금준 on 1/29/26.
//

import SwiftUI

// 검색 결과 타입을 구분하기 위한 Enum
enum SearchResultType {
    case hashTag(title: String)
    case member(imageUrl: String, title: String, subtitle: String)
}

struct RecentlySearchResultRow: View {
    let type: SearchResultType
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Group {
                switch type {
                case .hashTag:
                    Image("hashTag")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    
                case .member(let imageUrl, _, _):
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        case .failure:
                            Image("settingProfile")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                switch type {
                case .hashTag(let title):
                    Text(title)
                        .font(.codive_body1_medium)
                        .foregroundColor(Color.Codive.grayscale1)
                    
                case .member(_, let title, let subtitle):
                    Text(title)
                        .font(.codive_body1_medium)
                        .foregroundColor(Color.Codive.grayscale1)
                    Text(subtitle)
                        .font(.codive_body3_medium)
                        .foregroundColor(Color.Codive.grayscale3)
                }
            }
            
            Spacer()
  
            Button(
                action: {
                    onDelete()
                },
                label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
