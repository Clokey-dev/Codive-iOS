//
//  Router.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI
import Combine

@MainActor
final class Router: ObservableObject {
    
    // MARK: - Navigation Path
    @Published var path = NavigationPath()
    
    // MARK: - Navigation Methods
    
    /// 새로운 화면으로 이동 (스택에 추가)
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    /// 이전 화면으로 돌아가기
    func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// 루트 화면으로 돌아가기 (모든 스택 제거)
    func navigateToRoot() {
        path = NavigationPath()
    }
    
    /// 특정 화면으로 교체 (현재 스택을 모두 비우고 새로운 화면으로)
    func navigateAndReplace(to destination: Destination) {
        path = NavigationPath()
        path.append(destination)
    }
    
    /// 현재 경로의 깊이 확인
    var pathCount: Int {
        return path.count
    }
}
