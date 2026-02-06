//
//  HomeViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import Combine
import CoreLocation
import Photos

@MainActor
final class HomeViewModel: ObservableObject {
    
    static let codiTransferPublisher = CurrentValueSubject<TodayCodiTransferData?, Never>(nil)
    
    // MARK: - Properties (UI State)
    
    @Published var hasCodi: Bool = false
    @Published var showClothSelector: Bool = false
    @Published var selectedItemID: Int?
    @Published var selectedIndex: Int? = 0
    @Published var titleFrame: CGRect = .zero
    @Published var showCompletePopUp: Bool = false
    @Published var showLookBookSheet: Bool = false
    @Published var completedCodiImageURL: String?
    @Published var capturedImageURL: String?
    
    @Published var isEditingExistingCodi: Bool = false
    
    // MARK: - Properties (Data)
    
    @Published var weatherData: WeatherData?
    @Published var weatherErrorMessage: String?
    @Published var todayString: String = ""
    
    @Published var codiItems: [CodiItemEntity] = []
    @Published var selectedItemTags: [ClothTagEntity] = []
    @Published var activeCategories: [CategoryEntity] = []
    @Published var lookBookList: [LookBookBottomSheetEntity] = []
    @Published var clothItemsByCategory: [Int: [HomeClothEntity]] = [:]
    @Published var selectedIndicesByCategory: [Int: Int] = [:]
    @Published var selectedCodiClothes: [HomeClothEntity] = []
    @Published var todayCodiPreview: FetchTodayCoordinatePreviewResponseDTO?
    
    @Published var boardPayloads: [Payloads] = []
    
    // MARK: - Dependencies
    
    let navigationRouter: NavigationRouter
    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let todayCodiUseCase: TodayCodiUseCase
    private let dateUseCase: DateUseCase
    private let categoryUseCase: CategoryUseCase
    internal let addToLookBookUseCase: AddToLookBookUseCase
    
    // MARK: - Computed Properties
    
    /// 현재 활성화된 모든 카테고리에 아이템이 하나도 없는지 확인
    var isAllCategoriesEmpty: Bool {
        let totalItemCount = activeCategories.reduce(0) { sum, category in
            sum + (clothItemsByCategory[category.id]?.count ?? 0)
        }
        return totalItemCount == 0
    }
    
    // MARK: - Initializer
    
    init(
        navigationRouter: NavigationRouter,
        fetchWeatherUseCase: FetchWeatherUseCase,
        todayCodiUseCase: TodayCodiUseCase,
        dateUseCase: DateUseCase,
        categoryUseCase: CategoryUseCase,
        addToLookBookUseCase: AddToLookBookUseCase
    ) {
        self.navigationRouter = navigationRouter
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.todayCodiUseCase = todayCodiUseCase
        self.dateUseCase = dateUseCase
        self.categoryUseCase = categoryUseCase
        self.addToLookBookUseCase = addToLookBookUseCase
        
        loadInitialData()
    }
    
    // MARK: - Life Cycle
    
    func onAppear() {
        loadActiveCategories()
        fetchTodayCodiData()
    }
}

// MARK: - Data Loading Methods
extension HomeViewModel {
    
    /// 앱 실행 시 필요한 초기 데이터를 로드
    func loadInitialData() {
        loadToday()
        loadActiveCategories()
    }
    
    /// 현재 날짜 정보를 가져옴
    func loadToday() {
        let entity = dateUseCase.getToday()
        self.todayString = entity.formattedDate
    }
    
    /// 로컬에 저장된 활성화 카테고리 설정을 동기적으로 불러옴
    func loadActiveCategories() {
        let allCategories = categoryUseCase.loadCategories()
        self.activeCategories = allCategories.filter { $0.itemCount > 0 }
    }
    
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
                print("❌ 데이터 로드 실패: \(error)")
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
}

// MARK: - API & Async Methods
extension HomeViewModel {
    func loadWeather(for location: CLLocation?) async {
        do {
            let weather = try await fetchWeatherUseCase.execute(for: location)
            self.weatherData = weather
            
            let temperature = weather.currentTemp
            let request = PostTodayTemperatureAPIRequestDTO(
                temperature: Double(temperature)
            )
            try await fetchWeatherUseCase.postTodayTemp(request: request)
        } catch {
            weatherErrorMessage = TextLiteral.Home.failWeather
            print("Weather load or post failed:", error)
        }
    }
    
    /// 카테고리별 계절에 맞는 옷 조회
    func loadRecommendCategoryClothList() async {
        self.activeCategories = []
        self.clothItemsByCategory = [:]
        
        let allCategories = categoryUseCase.loadCategories()
        let filteredCategories = allCategories.filter { $0.itemCount > 0 }
        
        self.activeCategories = filteredCategories
        
        var resultMap: [Int: [HomeClothEntity]] = [:]
        
        for category in filteredCategories {
            do {
                let result = try await categoryUseCase.loadClothItems(
                    lastClothId: nil,
                    size: 10,
                    categoryId: Int64(category.id),
                    season: [.spring]
                )
                resultMap[category.id] = result.content
            } catch {
                print("Failed to load items for category \(category.id): \(error)")
                resultMap[category.id] = []
            }
        }
        
        self.clothItemsByCategory = resultMap
    }
}

// MARK: - UI Logic & Actions
extension HomeViewModel {
    
    /// 드래그를 통해 태그의 상대 위치를 업데이트
    func updateTagPosition(tagId: UUID, x: CGFloat, y: CGFloat, imageSize: CGSize) {
        if let index = selectedItemTags.firstIndex(where: { $0.id == tagId }) {
            selectedItemTags[index].locationX = x / imageSize.width
            selectedItemTags[index].locationY = y / imageSize.height
        }
    }
    
    /// 카테고리별로 선택된 의류의 인덱스를 업데이트
    func updateSelectedIndex(for categoryId: Int, index: Int) {
        selectedIndicesByCategory[categoryId] = index
    }
}

// MARK: - Navigation
extension HomeViewModel {
    
    /// 코디보드 화면으로 이동
    func handleCodiBoardTap() {
        let containerSize: CGFloat = 260
        // 보드 중앙 기준 좌표계로 변환하기 위한 오프셋
        let centerOffset = containerSize / 2
        
        let transferImages = activeCategories.enumerated().compactMap { index, category -> DraggableImageEntity? in
            guard let clothList = clothItemsByCategory[category.id],
                  let selectedIndex = selectedIndicesByCategory[category.id] else {
                return nil
            }
            
            let cloth = clothList.indices.contains(selectedIndex) ? clothList[selectedIndex] : clothList.first
            guard let selectedCloth = cloth else { return nil }
            
            let rawPos = CodiLayoutCalculator.position(
                index: index,
                totalCount: activeCategories.count,
                containerSize: containerSize
            )
            
            let relativePos = CGPoint(
                x: rawPos.x - centerOffset,
                y: rawPos.y - centerOffset
            )
            
            return DraggableImageEntity(
                id: selectedCloth.clothId,
                name: selectedCloth.imageUrl,
                position: relativePos,
                scale: 0.7,
                rotation: 0
            )
        }
        
        let data = TodayCodiTransferData(images: transferImages)
        
        Self.codiTransferPublisher.send(data)
        navigationRouter.navigate(to: .codiBoard)
    }
    
    /// 카테고리 편집 화면으로 이동
    func handleEditCategory() {
        navigationRouter.navigate(to: .editCategory)
    }
    
    /// 오늘의 코디 수정
    func selectEditCodi() {
        
        // 2. 수정 모드 플래그 활성화 및 화면 전환
        self.isEditingExistingCodi = true
        self.hasCodi = false
        
        Task {
            // 옷 리스트가 없으면 로드
            if clothItemsByCategory.isEmpty {
                await loadRecommendCategoryClothList()
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
            print("⚠️ [Save] 저장할 이미지 URL이 없습니다.")
            return
        }
        
        Task {
            do {
                // 2. 이미지 데이터 다운로드
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    print("⚠️ [Save] 이미지 변환 실패")
                    return
                }
                
                // 3. 사진첩 저장 실행
                saveToPhotoLibrary(image: image)
            } catch {
                print("❌ [Save] 다운로드 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveToPhotoLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    if success {
                        print("✅ 사진첩 저장 성공")
                    } else if let error = error {
                        print("❌ 저장 실패: \(error.localizedDescription)")
                    }
                }
            } else {
                print("⚠️ 사진첩 접근 권한이 거부되었습니다.")
            }
        }
    }
}

// MARK: - Popup & Decision Actions
extension HomeViewModel {
    func handleConfirmCodiTap() {
        let items = activeCategories
            .compactMap { category -> HomeClothEntity? in
                guard let clothList = clothItemsByCategory[category.id] else { return nil }
                let index = selectedIndicesByCategory[category.id] ?? 0
                return clothList.indices.contains(index) ? clothList[index] : clothList.first
            }
        
        self.selectedCodiClothes = items
        
        Task {
            var loadedImages: [Int64: UIImage] = [:]
            await withTaskGroup(of: (Int64, UIImage?).self) { group in
                for cloth in items {
                    group.addTask {
                        let image = await self.downloadUIImage(from: cloth.imageUrl)
                        return (cloth.clothId, image)
                    }
                }
                for await (id, image) in group {
                    if let img = image { loadedImages[id] = img }
                }
            }
            
            let captureView = CodiCompositeView(clothes: items, loadedImages: loadedImages)
                .frame(width: 260, height: 260)
            
            let renderer = ImageRenderer(content: captureView)
            renderer.scale = UIScreen.main.scale
            
            guard let uiImage = renderer.uiImage else {
                return
            }
            
            guard let jpgData = uiImage.jpegData(compressionQuality: 0.8) else { return }
            
            do {
                let uploadedURL = try await todayCodiUseCase.execute(jpgData: jpgData)
                
                await MainActor.run {
                    self.capturedImageURL = uploadedURL
                    self.showCompletePopUp = true
                    print("🚀 [Home Success] 최종 이미지 URL: \(uploadedURL)")
                }
            } catch {
                print("❌ [Home Capture] 서버 에러: \(error.localizedDescription)")
            }
        }
    }
    
    private func downloadUIImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("❌ 이미지 다운로드 실패 (\(urlString)): \(error)")
            return nil
        }
    }
    
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
    
    /// 팝업에서 '기록하기' 버튼을 눌러 오늘 완성한 코디를 서버에 전송
    // HomeViewModel.swift

    func handlePopupRecord() {
        Task {
            do {
                guard let imageURL = self.capturedImageURL else { return }
                
                // 1. 페이로드 추출 및 좌표 정밀도 보정 (소수점 4자리)
                let rawPayloads = boardPayloads.isEmpty ? createPayloadsFromCurrentList() : boardPayloads
                
                let finalPayloads = rawPayloads.map { p in
                    Payloads(
                        clothId: p.clothId,
                        locationX: (p.locationX * 10000).rounded() / 10000,
                        locationY: (p.locationY * 10000).rounded() / 10000,
                        ratio: (p.ratio * 100).rounded() / 100,
                        degree: (p.degree * 100).rounded() / 100,
                        order: Int32(p.order)
                    )
                }
                
                if isEditingExistingCodi, let coordinateId = todayCodiPreview?.coordinateId {
                    print("🔄 [PATCH] 오늘의 코디 수정 요청 (ID: \(coordinateId))")
                    
                    // 오늘의 코디는 name, memo를 지원하지 않을 확률이 높으므로 nil로 설정
                    // 만약 서버에서 필드 자체를 체크한다면, DTO에서 해당 필드들을 생략하고 보낼 필요가 있습니다.
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
                    print("✅ 오늘의 코디 수정 성공")
                    
                } else {
                    // 생성 모드 (기존과 동일)
                    let createRequest = CreateTodayCoordinateRequestDTO(
                        coordinateImageUrl: imageURL,
                        payloads: finalPayloads
                    )
                    let result = try await todayCodiUseCase.createTodayCoordinate(request: createRequest)
                    print("✅ 오늘의 코디 신규 생성 성공 (ID: \(result.coordinateId))")
                }
                
                await MainActor.run {
                    self.completeProcess()
                }
                
            } catch {
                print("\n❌ [최종 에러 보고]")
                print("- 에러 타입: \(error)")
                // 400 에러가 지속될 경우, 서버 명세서에서 PATCH의 payloads 필드명이 'Payload'인지 확인이 필요합니다.
            }
        }
    }

    private func completeProcess() {
        self.isEditingExistingCodi = false
        self.showCompletePopUp = false
        self.hasCodi = true
        self.boardPayloads = []
        self.capturedImageURL = nil
        self.fetchTodayCodiData() // 수정 완료 후 최신 데이터 다시 불러오기
    }

    // 상태 초기화 로직 분리
    private func resetUIStateAfterRecord() {
        self.isEditingExistingCodi = false
        self.showCompletePopUp = false
        self.hasCodi = true
        self.boardPayloads = []
        self.capturedImageURL = nil
        self.fetchTodayCodiData()
    }
    
    /// [Helper] 홈 화면의 현재 상태(순서/인덱스)를 기준으로 Payload 생성
    private func createPayloadsFromCurrentList() -> [Payloads] {
        let containerSize: CGFloat = 260
        
        // activeCategories의 현재 순서대로 옷을 찾아 좌표 부여
        return activeCategories.enumerated().compactMap { index, category -> Payloads? in
            guard let clothList = clothItemsByCategory[category.id] else { return nil }
            let selectedIndex = selectedIndicesByCategory[category.id] ?? 0
            let cloth = clothList.indices.contains(selectedIndex) ? clothList[selectedIndex] : clothList.first
            
            guard let selectedCloth = cloth else { return nil }
            
            // 리스트용 기본 좌표 계산
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
    
    /// 팝업을 닫기
    func handlePopupClose() {
        showCompletePopUp = false
        completedCodiImageURL = nil
    }
}

