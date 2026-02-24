//
//  Notification+Extensions.swift
//  Codive
//

import Foundation

extension Notification.Name {
    /// 사용자 차단 성공 시 발송되는 알림
    static let userDidBlock = Notification.Name("userDidBlock")

    /// 기록 생성/수정 완료 시 발송되는 알림
    static let feedDidCreate = Notification.Name("feedDidCreate")
}
