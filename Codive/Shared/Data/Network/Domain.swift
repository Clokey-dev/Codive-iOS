//
//  Domain.swift
//  Codive
//
//  Created by 황상환 on 9/21/25.
//

import Foundation

public struct API {
    
    /// 전체 서버의 공통 Base URL
    /// 각 Feature API의 path는 이 baseURL에 붙여서 구성
    public static let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? "https://api.codive.com"

    // MARK: - 주요 기능별 Endpoint 경로
    
    /// 인증 관련 API
    static let authURL = "\(baseURL)/auth"
    
    /// 유저 정보 관련 API
    static let userURL = "\(baseURL)/users"
}
