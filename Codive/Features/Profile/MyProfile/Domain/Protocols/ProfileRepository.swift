//
//  ProfileRepository.swift
//  Codive
//
//  Created by 황상환 on 1/25/26.
//

import Foundation

protocol ProfileRepository {
    func fetchMyProfile() async throws -> MyProfileInfo
    func fetchFollows(memberId: Int, isFollowing: Bool, lastFollowId: Int64?, size: Int32) async throws -> FollowListResult
    func updateProfile(nickname: String, bio: String, isPublic: Bool, currentImageUrl: String?) async throws -> MyProfileInfo
    func checkNicknameDuplicate(nickname: String) async throws -> Bool
    func uploadProfileImage(_ imageData: Data) async throws -> String
    func fetchMyFavoriteCoordinate() async throws -> [MyFavoriteLookBookResponseDTO]
    func fetchFavoriteCoordinate(memberId: Int) async throws -> [MyFavoriteLookBookResponseDTO]
    func fetchCoordinatePreview(coordinateId: Int64) async throws -> CoordinatePreviewEntity
    func fetchCoordinateDetail(
        coordinateId: Int64
    ) async throws -> [CoordinateDetailEntity]
}
