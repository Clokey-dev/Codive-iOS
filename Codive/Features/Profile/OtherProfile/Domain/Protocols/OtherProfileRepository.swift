//
//  OtherProfileRepository.swift
//  Codive
//
//  Created by 황상환 on 2026-02-05.
//

import Foundation

public protocol OtherProfileRepository {
    func fetchMemberInfo(memberId: Int) async throws -> OtherProfileEntity
    func toggleFollow(memberId: Int, isPublic: Bool) async throws
    func toggleBlock(memberId: Int) async throws
}
