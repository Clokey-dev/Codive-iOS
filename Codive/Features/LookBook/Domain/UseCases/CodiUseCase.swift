//
//  CodiUseCase.swift
//  Codive
//
//  Created by 한금준 on 12/23/25.
//

final class CodiUseCase {

    // MARK: - Dependency
    private let repository: LookBookRepository

    // MARK: - Initializer
    init(repository: LookBookRepository) {
        self.repository = repository
    }

    // MARK: - Codi Detail

    /// 코디 상세 정보 조회
    func fetchCodiDetail(codiId: Int) async throws -> CodiDetailEntity? {
        try await repository.fetchCodiDetail(codiId: codiId)
    }

    // MARK: - Like Action

    /// 코디 좋아요 상태 변경
    func toggleLike(codyId: Int, isLiked: Bool) async throws {
        try await repository.toggleLike(codyId: codyId, isLiked: isLiked)
    }
}
