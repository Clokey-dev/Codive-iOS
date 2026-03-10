//
//  HomeViewModel+CodiSave.swift
//  Codive
//
//  Created by 황상환 on 3/8/26.
//

import SwiftUI

// MARK: - Codi Save & Popup Actions
extension HomeViewModel {
    /// 코디 확정 후 완료 팝업을 표시
    func showCompletionPopup(imageURL: String?) {
        completedCodiImageURL = imageURL
        showCompletePopUp = true
    }

    func showCompletionFromBoard(payloads: [Payloads], imageURL: String) {
        self.boardPayloads = payloads
        self.capturedImageURL = imageURL
        self.showCompletePopUp = true
    }

    func handlePopupRecord() {
        Task {
            do {
                try await saveCoordinateToServer()

                // 코디 이미지를 다운로드하여 SelectedPhoto로 변환
                guard let imageURL = self.capturedImageURL,
                      let codiImage = await downloadUIImage(from: imageURL) else {
                    self.completeProcess()
                    return
                }

                // 1:1 → 3:4 비율 변환 (상하 여백 추가)
                let recordImage = Self.convertToThreeByFour(codiImage)

                let selectedPhoto = SelectedPhoto(
                    id: UUID().uuidString,
                    croppedImage: recordImage,
                    order: 1
                )

                // 상태 정리 후 기록 플로우로 이동
                self.completeProcess()
                self.navigationRouter.navigate(to: .recordDetail(photos: [selectedPhoto]))
            } catch {
                #if DEBUG
                print("[Home] 코디 저장 에러: \(error)")
                #endif
            }
        }
    }

    func handlePopupClose() {
        showCompletePopUp = false
        completedCodiImageURL = nil

        // 코디를 서버에 저장하고 오늘의 코디 새로고침
        Task {
            do {
                try await saveCoordinateToServer()
            } catch {
                #if DEBUG
                print("[Home] 코디 저장 에러: \(error)")
                #endif
            }
            self.completeProcess()
        }
    }
}

// MARK: - Private Helpers
extension HomeViewModel {
    /// 코디를 서버에 저장 (신규 생성 또는 수정)
    internal func saveCoordinateToServer() async throws {
        guard let imageURL = self.capturedImageURL else { return }

        let rawPayloads = boardPayloads.isEmpty ? createPayloadsFromCurrentList() : boardPayloads

        let finalPayloads = rawPayloads.map { p in
            Payloads(
                clothId: p.clothId,
                locationX: p.locationX,
                locationY: p.locationY,
                ratio: p.ratio,
                degree: p.degree,
                order: Int32(p.order)
            )
        }

        if isEditingExistingCodi, let coordinateId = todayCodiPreview?.coordinateId {
            let editRequest = EditCoordinateRequestDTO(
                coordinateImageUrl: imageURL,
                name: "\(todayString) 코디",
                memo: nil,
                payloads: finalPayloads
            )

            try await todayCodiUseCase.patchUpdateCoordinates(
                coordinateId: coordinateId,
                request: editRequest
            )
        } else {
            let createRequest = CreateTodayCoordinateRequestDTO(
                coordinateImageUrl: imageURL,
                payloads: finalPayloads
            )
            let result = try await todayCodiUseCase.createTodayCoordinate(request: createRequest)
            #if DEBUG
            print("[Home] 오늘의 코디 신규 생성 성공 (ID: \(result.coordinateId))")
            #endif
        }
    }

    internal func completeProcess() {
        self.isEditingExistingCodi = false
        self.showCompletePopUp = false
        self.boardPayloads = []
        self.capturedImageURL = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            self.hasCodi = true
        }
        self.fetchTodayCodiData()
    }

    /// 1:1 이미지를 3:4 비율로 변환 (상하에 배경색 여백 추가)
    internal static func convertToThreeByFour(_ image: UIImage) -> UIImage {
        let width = image.size.width
        let targetHeight = width * 4.0 / 3.0
        let yOffset = (targetHeight - image.size.height) / 2.0
        let targetSize = CGSize(width: width, height: targetHeight)
        let bgColor = UIColor(Color.Codive.grayscale7)

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { context in
            bgColor.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            image.draw(at: CGPoint(x: 0, y: yOffset))
        }
    }

    internal func createPayloadsFromCurrentList() -> [Payloads] {
        let containerSize: CGFloat = 260

        return activeCategories.enumerated().compactMap { index, category -> Payloads? in
            guard let clothList = clothItemsByCategory[category.id] else { return nil }
            let selectedIndex = selectedIndicesByCategory[category.id] ?? 0
            let cloth = clothList.indices.contains(selectedIndex) ? clothList[selectedIndex] : clothList.first

            guard let selectedCloth = cloth else { return nil }

            let position = CodiLayoutCalculator.position(
                index: index,
                totalCount: activeCategories.count,
                containerSize: containerSize
            )

            return Payloads(
                clothId: selectedCloth.clothId,
                locationX: Double(position.x / containerSize),
                locationY: Double(position.y / containerSize),
                ratio: 1.0,
                degree: 0,
                order: Int32(index + 1)
            )
        }
    }
}
