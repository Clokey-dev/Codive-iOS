//
//  HomeViewModel+.swift
//  Codive
//
//  Created by 한금준 on 2/6/26.
//

import SwiftUI

// MARK: - LookBook Actions
extension HomeViewModel {
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
                print("❌ 룩북 리스트 로드 실패: \(error.localizedDescription)")
            }
        }
    }
    /// 바텀시트에서 특정 룩북을 선택
    func selectLookBook(_ entity: LookBookBottomSheetEntity) {
        showLookBookSheet = false
    }
}

extension HomeViewModel {
    /// 카테고리 순서 변경
    func moveCategory(from source: IndexSet, to destination: Int) {
        activeCategories.move(fromOffsets: source, toOffset: destination)
        
        // 순서 변경을 로컬에 저장하려면 categoryUseCase를 통해 저장
        // categoryUseCase.saveCategoryOrder(activeCategories)
    }
    
    /// 이미지 캡처
    private func captureCompletedCodiImage() -> UIImage {
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
}
