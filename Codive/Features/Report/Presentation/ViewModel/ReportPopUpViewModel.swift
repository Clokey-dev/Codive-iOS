//
//  ReportPopUpViewModel.swift
//  Codive
//
//  Created by 한태빈 on 11/10/25.
//

import SwiftUI

@MainActor
final class ReportPopupViewModel: ObservableObject {
    let target: ReportTarget
    let itemTitle: String
    let reasonText: String

    init(target: ReportTarget, itemTitle: String, reasonText: String) {
        self.target = target
        self.itemTitle = itemTitle
        self.reasonText = reasonText
    }

    var headerLine1: String { "신고 접수된" }
    var headerLine2: String { "\(target.labelForUI)이 있습니다." }

    var middleLine1: String { "신고당한 \(target.labelForUI) : \(itemTitle)" }
    var middleLine2: String { "신고 사유 : \(reasonText)" }
}

// UI 표기 위함
private extension ReportTarget {
    var labelForUI: String {
        switch self {
        case .post:    return "게시글"
        case .comment: return "댓글"
        }
    }
}
