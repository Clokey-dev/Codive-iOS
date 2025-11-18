//
//  RecordDetailViewModel.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - RecordDetailViewModel
@MainActor
final class RecordDetailViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var selectedPhotos: [SelectedPhoto]
    @Published var currentPhotoIndex: Int = 0
    
    // MultiSelect Properties
    @Published var selectedStyles: Set<String> = []
    @Published var selectedSituations: Set<String> = []
    
    // TextField Property
    @Published var captionText: String = "" {
        didSet {
            processHashtags(captionText)
        }
    }
    
    @Published var hashtags: [String] = []
    @Published var attributedCaption: AttributedString = AttributedString("")
    
    private let navigationRouter: NavigationRouter
    
    // MARK: - Options
    let styleOptions = ["캐주얼", "러블리", "미니멀", "빈티지", "스포티", "스트릿", "시크", "오피스룩", "클래식", "하이틴"]
    let situationOptions = ["데이트", "데일리", "여행", "운동", "축제", "출근복", "파티"]
    
    // MARK: - Computed Properties
    var currentPhoto: SelectedPhoto? {
        guard selectedPhotos.indices.contains(currentPhotoIndex) else { return nil }
        return selectedPhotos[currentPhotoIndex]
    }
    
    var isCompleteEnabled: Bool {
        // 스타일 최소 1개, 최대 3개 선택 필수
        return selectedStyles.count >= 1 && selectedStyles.count <= 3
    }
    
    // MARK: - Initializer
    init(selectedPhotos: [SelectedPhoto], navigationRouter: NavigationRouter) {
        self.selectedPhotos = selectedPhotos
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Methods
    func updateCurrentPhotoIndex(_ index: Int) {
        currentPhotoIndex = index
    }
    
    func completeRecord() {
        // TODO: 기록 저장 로직
        print("기록 완료")
        print("선택된 스타일: \(selectedStyles)")
        print("선택된 상황: \(selectedSituations)")
        print("캡션: \(captionText)")
        
        // 메인으로 돌아가기
        navigationRouter.navigateToRoot()
    }
    
    func navigateToPhotoTag() {
        guard let currentPhoto = currentPhoto else { return }
        navigationRouter.navigate(to: .photoTag(photo: currentPhoto, allPhotos: selectedPhotos))
    }
    
    func dismissView() {
        navigationRouter.navigateBack()
    }
    
    private func processHashtags(_ text: String) {
        var attributed = AttributedString(text)
        var foundHashtags: [String] = []
        
        // 해시태그 패턴: # 뒤에 한글/영문/숫자가 1개 이상
        let pattern = "(?<!#)#(?!#)[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            self.attributedCaption = attributed
            return
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            let matchedString = nsString.substring(with: match.range)
            foundHashtags.append(matchedString)
            
            if let range = Range(match.range, in: text) {
                let attributedRange = AttributedString.Index(range.lowerBound, within: attributed)!
                ..< AttributedString.Index(range.upperBound, within: attributed)!
                
                attributed[attributedRange].foregroundColor = Color.Codive.point1
            }
        }
        
        self.hashtags = foundHashtags
        self.attributedCaption = attributed
    }
}
