//
//  ProfileRepositoryImpl.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

import Foundation

final class ProfileRepositoryImpl: ProfileRepository {
    private let dataSource: ProfileDataSourceProtocol

    init(dataSource: ProfileDataSourceProtocol) {
        self.dataSource = dataSource
    }

    func fetchMyProfile() async throws -> MyProfileInfo {
        return try await dataSource.fetchMyProfile()
    }

    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult {
        return try await dataSource.fetchFollows(memberId: memberId, isFollowing: isFollowing, lastFollowId: lastFollowId, size: size)
    }

    func updateProfile(nickname: String, bio: String, isPublic: Bool, currentImageUrl: String?) async throws -> MyProfileInfo {
        return try await dataSource.updateProfile(nickname: nickname, bio: bio, isPublic: isPublic, currentImageUrl: currentImageUrl)
    }

    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        return try await dataSource.checkNicknameDuplicate(nickname: nickname)
    }

    func uploadProfileImage(_ imageData: Data) async throws -> String {
        return try await dataSource.uploadProfileImage(imageData)
    }
    
    func fetchMyFavoriteCoordinate(memberId: String?) async throws -> [MyFavoriteLookBookResponseDTO] {
        return try await dataSource.fetchMyFavoriteCoordinate(memberId: memberId)
    }

    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewEntity {
        let dto = try await dataSource.fetchCoordinatePreview(coordinateId: coordinateId)
        return dto.toEntity()
    }

    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailEntity] {
        
        let dtoList = try await dataSource.fetchCoordinateDetail(
            coordinateId: coordinateId
        )
        
        return dtoList.map { $0.toEntity() }
    }
}
