//
//  LocationService.swift
//  Codive
//
//  Created by 한금준 on 11/13/25.
//

import CoreLocation
import Combine

protocol LocationService {
    func getCurrentLocation() async throws -> CLLocation
}

final class SystemLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    // Continiation을 캡슐화하여 nil 체크 없이 안전하게 호출할 수 있는 구조로 변경
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    // 위치 권한 상태를 저장하는 변수 추가
    private var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
        // 초기 권한 상태를 manager에서 가져와 저장
        self.authorizationStatus = manager.authorizationStatus
        
        // 초기 권한 요청 (init에서 한 번 호출)
        manager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        // 1. 현재 권한 상태 확인
        let currentStatus = manager.authorizationStatus
        if currentStatus == .denied || currentStatus == .restricted {
            // 권한이 거부된 상태라면 즉시 에러 반환 (CLError.denied 코드 1과 일치)
            let deniedError = NSError(domain: kCLErrorDomain, code: CLError.Code.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "위치 권한이 거부되어 날씨 정보를 불러올 수 없습니다."])
            throw deniedError
        }
        
        // 2. 비동기 블록에서 Continuation 설정
        return try await withCheckedThrowingContinuation { continuation in
            // 이전 요청이 있다면 에러 처리 (동시 요청 방지)
            if self.locationContinuation != nil {
                 continuation.resume(throwing: NSError(domain: "LocationError", code: 99, userInfo: [NSLocalizedDescriptionKey: "위치 요청이 이미 진행 중입니다."]))
                 return
            }
            
            self.locationContinuation = continuation
            
            // 3. 위치 요청 시작
            // 권한이 이미 승인된 상태라면 바로 위치 업데이트를 요청
            if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
                self.manager.requestLocation()
            } else {
                // 아직 권한을 요청하지 않았거나 결정되지 않았다면 (notDetermined),
                // locationManagerDidChangeAuthorization에서 requestLocation()을 호출할 것이므로 대기
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        // ⭐️ 성공 시, Continuation 재개 후 nil로 설정
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
        manager.stopUpdatingLocation() // 단발성 요청이므로 중지
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
        print("Location Manager failed:", error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        self.authorizationStatus = newStatus
        
        // 권한이 승인되었을 때, 대기 중인 Continuation이 있다면 위치 요청 재시작
        if (newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways) {
            // Continuation이 존재하는 경우에만 위치 요청 재시도
            if locationContinuation != nil {
                manager.requestLocation()
            }
        }
        
        // 권한이 거부된 경우, 대기 중인 Continuation에게 에러 전달
        else if (newStatus == .denied || newStatus == .restricted) {
            let deniedError = NSError(domain: kCLErrorDomain, code: CLError.Code.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "위치 권한이 거부되어 날씨 정보를 불러올 수 없습니다."])
            locationContinuation?.resume(throwing: deniedError)
            locationContinuation = nil
        }
    }
}
