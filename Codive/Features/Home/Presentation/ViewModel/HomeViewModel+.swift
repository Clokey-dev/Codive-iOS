//
//  HomeViewModel+.swift
//  Codive
//
//  Created by 한금준 on 2/6/26.
//

import SwiftUI
import Photos

// MARK: - LookBook Actions
extension HomeViewModel {
    /// 오늘의 코디 수정
    func selectEditCodi() {
        
        // 2. 수정 모드 플래그 활성화 및 화면 전환
        self.isEditingExistingCodi = true
        self.hasCodi = false
        
        Task {
            // 옷 리스트가 없으면 로드
            if clothItemsByCategory.isEmpty {
                await loadRecommendCategoryClothList(seasons: self.currentSeasons)
            }
            
            var restoredIndices: [Int: Int] = [:]
            
            for item in codiItems {
                if let category = activeCategories.first(where: { $0.title == item.parentCategory }) {
                    if let clothList = clothItemsByCategory[category.id],
                       let index = clothList.firstIndex(where: { $0.clothId == item.clothId }) {
                        restoredIndices[category.id] = index
                    }
                }
            }
            
            await MainActor.run {
                self.selectedIndicesByCategory = restoredIndices
            }
        }
    }
    
    /// 수정 취소 또는 뒤로가기 시 상태를 복구하고 싶을 때 사용 (선택 사항)
    func cancelEditCodi() {
        if todayCodiPreview != nil {
            self.hasCodi = true
        }
    }
    
    func sharedCodi() {
        // 1. 저장할 이미지 URL 확인
        guard let imageUrlString = todayCodiPreview?.imageUrl,
              let url = URL(string: imageUrlString) else {
            #if DEBUG
            print("[Save] 저장할 이미지 URL이 없습니다.")
            #endif
            return
        }
        
        Task {
            do {
                // 2. 이미지 데이터 다운로드
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    #if DEBUG
                    print("[Save] 이미지 변환 실패")
                    #endif
                    return
                }
                
                // 3. 사진첩 저장 실행
                saveToPhotoLibrary(image: image)
            } catch {
                #if DEBUG
                print("[Save] 다운로드 실패: \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    private func saveToPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    #if DEBUG
                    if success {
                        print("[Save] 사진첩 저장 성공")
                    } else if let error = error {
                        print("[Save] 저장 실패: \(error.localizedDescription)")
                    }
                    #endif
                }
            } else {
                #if DEBUG
                print("[Save] 사진첩 접근 권한이 거부되었습니다.")
                #endif
            }
        }
    }
    /// 내 룩북 리스트를 불러와 바텀시트를 표시
    func addLookbook() {
        Task {
            do {
                let (content, _) = try await addToLookBookUseCase.fetchLookBookList(
                    lastLookBookId: nil,
                    size: 20,
                    direction: .DESC
                )
                
                self.lookBookList = content.map { entity in
                    LookBookBottomSheetEntity(
                        lookbookId: entity.lookBookId,
                        imageUrl: entity.imageUrl,
                        title: entity.lookbookName,
                        count: entity.count
                    )
                }
                
                self.showLookBookSheet = true
            } catch {
                #if DEBUG
                print("[Lookbook] 룩북 리스트 로드 실패: \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    func selectLookBook(_ entity: LookBookBottomSheetEntity) {
        guard let dailyCodiId = todayCodiPreview?.coordinateId else {
            #if DEBUG
            print("[Lookbook] 추가할 오늘의 코디 정보가 없습니다.")
            #endif
            return
        }
        
        Task {
            do {
                let request = CreateAutoDailyCoordinateAPIRequestDTO(
                    name: "\(todayString) 코디",
                    memo: "",
                    dailyCoordinateId: dailyCodiId,
                    lookBookId: entity.lookbookId
                )
                
                _ = try await addToLookBookUseCase.createAutoDailyCoordinate(request: request)
                
                await MainActor.run {
                    self.showLookBookSheet = false
                }
            } catch {
                #if DEBUG
                print("[Lookbook] 룩북 추가 실패: \(error.localizedDescription)")
                #endif
            }
        }
    }
}

extension HomeViewModel {
    /// 오늘의 코디 조회
    func fetchTodayCodiData() {
        guard !isEditingExistingCodi else { return }
        Task {
            do {
                // 1. 배경 이미지(Preview)와 상세 정보(Details)를 병렬로 호출
                async let previewReq = todayCodiUseCase.fetchTodayCoordinatePreview()
                async let detailsReq = todayCodiUseCase.fetchTodayCoordinateDetails()
                
                let (preview, details) = try await (previewReq, detailsReq)
                
                self.todayCodiPreview = preview
                
                // 2. 서버 응답 DTO를 UI에서 사용하는 CodiItemEntity로 매핑
                self.codiItems = details.map { detail in
                    CodiItemEntity(
                        coordinateClothId: detail.coordinateClothId,
                        locationX: detail.locationX,
                        locationY: detail.locationY,
                        ratio: detail.ratio,
                        degree: detail.degree,
                        order: detail.order,
                        clothId: detail.clothId,
                        imageUrl: detail.imageUrl,
                        brand: detail.brand,
                        name: detail.name,
                        category: detail.category,
                        parentCategory: detail.parentCategory
                    )
                }
                
                self.hasCodi = true
            } catch {
                self.hasCodi = false
                #if DEBUG
                print("[Home] 데이터 로드 실패: \(error)")
                #endif
            }
        }
    }
    
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector { selectedItemID = nil }
        }
    }
    
    func selectItem(_ id: Int?) {
        withAnimation(.spring()) {
            selectedItemID = id
        }
    }

    func captureCompletedCodiImage() -> UIImage {
        let view = CodiCompositeView(clothes: selectedCodiClothes)
            .frame(width: 260, height: 260)

        let controller = UIHostingController(rootView: view)
        let uiView = controller.view!
        uiView.bounds = CGRect(origin: .zero, size: CGSize(width: 260, height: 260))
        uiView.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 260, height: 260))
        return renderer.image { _ in
            uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
        }
    }

    func downloadUIImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            #if DEBUG
            print("[Home] 이미지 다운로드 실패 (\(urlString)): \(error)")
            #endif
            return nil
        }
    }

    /// 드래그를 통해 태그의 상대 위치를 업데이트
    func updateTagPosition(tagId: UUID, x: CGFloat, y: CGFloat, imageSize: CGSize) {
        if let index = selectedItemTags.firstIndex(where: { $0.id == tagId }) {
            selectedItemTags[index].locationX = x / imageSize.width
            selectedItemTags[index].locationY = y / imageSize.height
        }
    }
}
