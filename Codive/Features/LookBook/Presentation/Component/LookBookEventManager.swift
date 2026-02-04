//
//  LookBookEventManager.swift
//  Codive
//
//  Created by 한금준 on 2/4/26.
//

import Combine

final class LookBookEventManager {
    static let shared = LookBookEventManager()
    private init() {}

    // PassthroughSubject 대신 CurrentValueSubject 사용
    // 초기값은 false로 설정
    let shouldShowAddDialog = CurrentValueSubject<Bool, Never>(false)
}
