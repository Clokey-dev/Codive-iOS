//
//  AppDelegate.swift
//  Codive
//
//  Created by Claude on 4/26/26.
//

import UIKit
import FirebaseMessaging
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {

    /// 앱이 죽어있을 때 푸시 탭으로 실행된 경우 저장해두는 pending 데이터
    static var pendingPushUserInfo: [AnyHashable: Any]?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        requestNotificationPermission(application)

        return true
    }

    // MARK: - APNs Token

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        #if DEBUG
        print("[Push] APNs 등록 실패: \(error.localizedDescription)")
        #endif
    }

    // MARK: - Permission

    private func requestNotificationPermission(_ application: UIApplication) {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            #if DEBUG
            if let error {
                print("[Push] 권한 요청 실패: \(error.localizedDescription)")
            } else {
                print("[Push] 알림 권한 허용: \(granted)")
            }
            #endif

            guard granted else { return }

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    // 포그라운드에서 알림 수신 시 배너 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    // 알림 탭 시 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        #if DEBUG
        print("[Push] 알림 탭 userInfo: \(userInfo)")
        #endif

        // MainTabView가 아직 없으면 pending으로 저장, 있으면 바로 전달
        AppDelegate.pendingPushUserInfo = userInfo

        NotificationCenter.default.post(
            name: .pushNotificationTapped,
            object: nil,
            userInfo: userInfo
        )

        completionHandler()
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }

        #if DEBUG
        print("[Push] FCM 토큰: \(fcmToken)")
        #endif

        // UserDefaults에 저장 (로그인 후 서버 전송용)
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")

        // 로그인 상태면 서버에 즉시 전송
        Task {
            await sendFCMTokenToServerIfNeeded(fcmToken)
        }
    }

    @MainActor
    private func sendFCMTokenToServerIfNeeded(_ fcmToken: String) async {
        let tokenService = TokenService()

        guard tokenService.hasValidTokens(),
              !tokenService.isAccessTokenExpired() else {
            return
        }

        do {
            let authAPIService = AuthAPIService()
            try await authAPIService.renewDeviceToken(deviceToken: fcmToken)
            #if DEBUG
            print("[Push] 서버에 FCM 토큰 전송 완료")
            #endif
        } catch {
            #if DEBUG
            print("[Push] 서버 FCM 토큰 전송 실패: \(error.localizedDescription)")
            #endif
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let pushNotificationTapped = Notification.Name("pushNotificationTapped")
}
