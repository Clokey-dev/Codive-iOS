//
//  HomeViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import Combine
import CoreLocation

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
    private let addToLookBookUseCase: AddToLookBookUseCase
    
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
        fetchTodayCodiPreview()
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
    
    func fetchTodayCodiPreview() {
        Task {
            do {
                // UseCase를 통해 서버의 Preview 정보 조회
                let preview = try await todayCodiUseCase.fetchTodayCoordinatePreview()
                
                await MainActor.run {
                    self.todayCodiPreview = preview
                    // 데이터가 성공적으로 들어오면 hasCodi를 true로 변경하여
                    // HomeView에서 HomeHasCodiView를 그리도록 유도합니다.
                    self.hasCodi = true
                }
            } catch {
                // 코디가 없는 경우(404 등)에는 hasCodi를 false로 유지합니다.
                await MainActor.run {
                    self.hasCodi = false
                }
                print("❌ 오늘의 코디 데이터 없음 또는 로드 실패: \(error.localizedDescription)")
            }
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
    
    /// 코디 이미지 내의 태그 표시 셀렉터를 토글
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            if !showClothSelector {
                selectedItemID = nil
                selectedItemTags = []
            }
        }
    }
    
    /// 코디판 이미지 중 특정 아이템을 선택하여 태그를 표시
    func selectItem(_ id: Int?) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedItemID = id
            guard let id = id, let item = codiItems.first(where: { $0.id == id }) else {
                self.selectedItemTags = []
                return
            }
            
            self.selectedItemTags = [
                ClothTagEntity(
                    title: item.brandName,
                    content: item.clothName,
                    locationX: 0.5,
                    locationY: 0.5
                )
            ]
        }
    }
    
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
    
    /// 룩북으로 이동
    func selectEditCodi() {
        navigationRouter.navigate(to: .lookbook)
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
    func handlePopupRecord() {
        Task {
            do {
                guard let imageURL = self.capturedImageURL else {
                    print("⚠️ [Error] 이미지 URL이 없습니다.")
                    return
                }
 
                let finalPayloads: [Payloads]
                
                if !boardPayloads.isEmpty {
                    finalPayloads = boardPayloads
                } else {
                    finalPayloads = createPayloadsFromCurrentList()
                }
                
                let request = CreateTodayCoordinateRequestDTO(
                    coordinateImageUrl: imageURL,
                    payloads: finalPayloads
                )
     
                let result = try await todayCodiUseCase.createTodayCoordinate(request: request)
 
                await MainActor.run {
                    self.showCompletePopUp = false
                    self.hasCodi = true
                    self.boardPayloads = []
                    self.capturedImageURL = nil
                    print("✅ 오늘의 코디 저장 성공: \(result.coordinateId)")
                }
            } catch {
                print("❌ 최종 코디 저장 실패: \(error.localizedDescription)")
            }
        }
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

extension UIImage {
    func toBase64String() -> String? {
        guard let data = self.jpegData(compressionQuality: 0.9) else {
            return nil
        }
        return data.base64EncodedString()
    }
}
