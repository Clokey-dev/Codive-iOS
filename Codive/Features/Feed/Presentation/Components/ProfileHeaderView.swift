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
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onProfileTap) {
                AsyncImage(url: URL(string: profileImageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button(action: onProfileTap) {
                Text(nickname)
                    .font(.codive_body2_medium)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .buttonStyle(.plain)

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
