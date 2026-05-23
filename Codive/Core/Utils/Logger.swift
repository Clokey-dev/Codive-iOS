//
//  Logger.swift
//  Codive
//
//  os.Logger 기반 통합 로깅 래퍼.
//  Release 빌드에서는 .debug 레벨이 자동 무시되며,
//  민감 정보(토큰 등)는 `masked()` 헬퍼로 마스킹하여 기록한다.
//

import Foundation
import OSLog

enum AppLog {
    private static let subsystem = "com.codive.app"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let network = Logger(subsystem: subsystem, category: "network")
    static let api = Logger(subsystem: subsystem, category: "api")
    static let push = Logger(subsystem: subsystem, category: "push")
    static let deeplink = Logger(subsystem: subsystem, category: "deeplink")
    static let ui = Logger(subsystem: subsystem, category: "ui")
}

extension String {
    /// 민감 문자열의 앞 일부만 노출하고 나머지는 마스킹.
    /// - Parameter visible: 앞에서 그대로 보여줄 문자 수 (기본 8)
    func masked(visible: Int = 8) -> String {
        guard count > visible else { return "***" }
        return prefix(visible) + "...(\(count))"
    }
}
