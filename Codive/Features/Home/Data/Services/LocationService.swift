//
//  LocationService.swift
//  Codive
//
//  Created by 한금준 on 11/13/25.
//

import CoreLocation
import Combine

// MARK: - LocationService Protocol
protocol LocationService {
    func getCurrentLocation() async throws -> CLLocation
}

// MARK: - SystemLocationService
final class SystemLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    
    // MARK: - Properties
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Initializer
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
        self.authorizationStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        let currentStatus = manager.authorizationStatus
        if currentStatus == .denied || currentStatus == .restricted {
            let deniedError = NSError(domain: kCLErrorDomain, code: CLError.Code.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "위치 권한이 거부되어 날씨 정보를 불러올 수 없습니다."])
            throw deniedError
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            if self.locationContinuation != nil {
                continuation.resume(throwing: NSError(domain: "LocationError", code: 99, userInfo: [NSLocalizedDescriptionKey: "위치 요청이 이미 진행 중입니다."]))
                return
            }
            
            self.locationContinuation = continuation
            
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
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
        #if DEBUG
        print("[Location] Manager failed:", error.localizedDescription)
        #endif
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        self.authorizationStatus = newStatus

        if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
            if locationContinuation != nil {
                manager.requestLocation()
            }
        } else if newStatus == .denied || newStatus == .restricted {
            let deniedError = NSError(
                domain: kCLErrorDomain,
                code: CLError.Code.denied.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: "위치 권한이 거부되어 날씨 정보를 불러올 수 없습니다."
                ]
            )
            locationContinuation?.resume(throwing: deniedError)
            locationContinuation = nil
        }
    }
}
