//
//  NavigationRouter.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI
import Combine

@MainActor
final class NavigationRouter: ObservableObject {
    
    // MARK: - Properties
    @Published var path = NavigationPath()
    @Published var currentDestination: AppDestination?
    @Published var sheetDestination: AppDestination?
    
    /// 탭 전환 요청 (MainTabView에서 구독)
    @Published var pendingTabSwitch: TabBarType?
    
    /// 성공 오버레이 표시 (앱 레벨에서 관리)
    @Published var successMessage: String?
    
    // MARK: - Navigation Methods

    /// 새로운 화면으로 이동 (스택에 추가)
    func navigate(to destination: AppDestination) {
        currentDestination = destination
        path.append(destination)
    }

    /// 이전 화면으로 돌아가기
    func navigateBack() {
        if sheetDestination != nil {
            dismissSheet()
            return
        }
        
        guard !path.isEmpty else { return }
        path.removeLast()

        if path.isEmpty {
            currentDestination = nil
        }
    }
    
    /// 루트 화면으로 돌아가기 (모든 스택 제거)
    func navigateToRoot() {
        path = NavigationPath()
        currentDestination = nil
        dismissSheet()
    }
    
    /// 특정 화면으로 교체 (현재 스택을 모두 비우고 새로운 화면으로)
    func navigateAndReplace(to destination: AppDestination) {
        path = NavigationPath()
        currentDestination = destination
        path.append(destination)
    }

    /// 탭 전환 후 특정 화면으로 이동
    func switchTabAndNavigate(to tab: TabBarType, destination: AppDestination? = nil) {
        path = NavigationPath()
        currentDestination = nil
        pendingTabSwitch = tab

        if let destination = destination {
            // 약간의 딜레이 후 네비게이션 (탭 전환이 완료된 후)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.navigate(to: destination)
            }
        }
    }

    /// 성공 화면을 보여주면서 탭 전환 후 네비게이션 (성공 화면이 덮고 있는 동안 뒤에서 이동)
    func showSuccessAndNavigate(message: String, to tab: TabBarType, destination: AppDestination? = nil, duration: TimeInterval = 1.5) {
        // 1. 성공 오버레이 표시
        successMessage = message

        // 2. 뒤에서 탭 전환 + 네비게이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.switchTabAndNavigate(to: tab, destination: destination)
        }

        // 3. duration 후 성공 오버레이 닫기
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.successMessage = nil
            }
        }
    }
    
    // MARK: - Sheet Presentation Methods
    
    /// 시트를 표시합니다.
    func presentSheet(for destination: AppDestination) {
        sheetDestination = destination
    }
    
    /// 현재 표시된 시트를 닫습니다.
    func dismissSheet() {
        sheetDestination = nil
    }
    
    // MARK: - Computed Properties
    
    /// 현재 경로의 깊이 확인
    var pathCount: Int {
        return path.count
    }
}
