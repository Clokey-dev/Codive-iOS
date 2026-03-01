//
//  ProfileDataSource.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

import Foundation

protocol ProfileDataSourceProtocol {
    func fetchMyProfile() async throws -> MyProfileInfo
    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult
    func updateProfile(nickname: String, bio: String, isPublic: Bool, currentImageUrl: String?) async throws -> MyProfileInfo
    func checkNicknameDuplicate(nickname: String) async throws -> Bool
    func uploadProfileImage(_ imageData: Data) async throws -> String
    func fetchMyFavoriteCoordinate(memberId: String?) async throws -> [MyFavoriteLookBookResponseDTO]
    /// 코디 preview 조회
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO
    
    /// 코디 detail 조회
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO]
}

final class ProfileDataSource: ProfileDataSourceProtocol {
    private let apiService: ProfileAPIServiceProtocol

    init(apiService: ProfileAPIServiceProtocol = ProfileAPIService()) {
        self.apiService = apiService
    }

    func fetchMyProfile() async throws -> MyProfileInfo {
        return try await apiService.fetchMyProfile()
    }

    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult {
        return try await apiService.fetchFollows(memberId: memberId, isFollowing: isFollowing, lastFollowId: lastFollowId, size: size)
    }

    func updateProfile(nickname: String, bio: String, isPublic: Bool, currentImageUrl: String?) async throws -> MyProfileInfo {
        return try await apiService.updateProfile(nickname: nickname, bio: bio, isPublic: isPublic, currentImageUrl: currentImageUrl)
    }

    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        return try await apiService.checkNicknameDuplicate(nickname: nickname)
    }

    func uploadProfileImage(_ imageData: Data) async throws -> String {
        return try await apiService.uploadProfileImage(imageData)
    }
    
    func fetchMyFavoriteCoordinate(memberId: String?) async throws -> [MyFavoriteLookBookResponseDTO] {
        return try await apiService.fetchMyFavoriteCoordinate(memberId: memberId)
    }

    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewResponseDTO {
        return try await apiService.fetchCoordinatePreview(coordinateId: coordinateId)
    }

    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailResponseDTO] {
        return try await apiService.fetchCoordinateDetail(coordinateId: coordinateId)
    }
}
