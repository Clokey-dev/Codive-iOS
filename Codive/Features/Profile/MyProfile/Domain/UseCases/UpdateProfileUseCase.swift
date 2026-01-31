//
//  UpdateProfileUseCase.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

import Foundation

protocol UpdateProfileUseCase {
    func execute(
        nickname: String,
        bio: String,
        isPublic: Bool,
        imageData: Data?
    ) async throws -> MyProfileInfo
}

final class DefaultUpdateProfileUseCase: UpdateProfileUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(
        nickname: String,
        bio: String,
        isPublic: Bool,
        imageData: Data?
    ) async throws -> MyProfileInfo {
        // 이미지가 있으면 먼저 업로드
        var imageUrlToUpdate: String? = nil
        if let imageData = imageData {
            imageUrlToUpdate = try await repository.uploadProfileImage(imageData)
        }

        // 프로필 수정
        return try await repository.updateProfile(
            nickname: nickname,
            bio: bio,
            isPublic: isPublic,
            currentImageUrl: imageUrlToUpdate
        )
    }
}
