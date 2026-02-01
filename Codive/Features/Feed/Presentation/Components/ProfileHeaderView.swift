//
//  ProfileHeaderView.swift
//  Codive
//
//  Created by 황상환 on 12/3/25.
//

import SwiftUI

struct ProfileHeaderView: View {
    let profileImageUrl: String
    let nickname: String
    let onMoreTap: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // TODO: API 연동 시 profileImageUrl을 사용하여 비동기 이미지 로딩 (KingFisher 또는 AsyncImage)
            Image("Profile")
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            Text(nickname)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
            
            Spacer()
            
            Button(action: onMoreTap) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(Color.Codive.grayscale3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
