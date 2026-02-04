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
    }
}

// MARK: - Data Loading Methods
extension HomeViewModel {
    
    /// 앱 실행 시 필요한 초기 데이터를 로드
    func loadInitialData() {
//        loadDummyCodi()
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
    
//    /// 오늘 이미 생성된 코디(더미) 데이터를 불러옴
//    func loadDummyCodi() {
//        codiItems = todayCodiUseCase.loadTodaysCodi()
//    }
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
    
    /// 현재 스크롤된 의류 조합을 수집하고 완료 팝업을 띄움
//    func handleConfirmCodiTap() {
//        let items = activeCategories
//            .sorted { $0.id < $1.id }
//            .compactMap { category -> HomeClothEntity? in
//                guard let clothList = clothItemsByCategory[category.id] else { return nil }
//                let index = selectedIndicesByCategory[category.id] ?? 0
//                return clothList.indices.contains(index) ? clothList[index] : clothList.first
//            }
//        
//        self.selectedCodiClothes = items
//        self.showCompletePopUp = true
//    }
    func handleConfirmCodiTap() {
        // 1. 현재 선택된 옷 리스트 수집
        let items = activeCategories
            .compactMap { category -> HomeClothEntity? in
                guard let clothList = clothItemsByCategory[category.id] else { return nil }
                let index = selectedIndicesByCategory[category.id] ?? 0
                return clothList.indices.contains(index) ? clothList[index] : clothList.first
            }
        
        self.selectedCodiClothes = items
        
        // 2. 비동기 캡처 및 업로드 시작
        Task {
            // 캡처할 뷰 생성
            let captureView = CodiCompositeView(clothes: items)
                .frame(width: 260, height: 260)
            
            // ImageRenderer 설정
            let renderer = ImageRenderer(content: captureView)
            renderer.scale = UIScreen.main.scale
            
            // 이미지 데이터 변환 및 업로드 (사용자가 제시한 로직 적용)
            guard let uiImage = renderer.uiImage,
                  let jpgData = uiImage.jpegData(compressionQuality: 0.8) else {
                return
            }
            
            do {
                // 서버에 업로드하고 URL 수신
                let uploadedURL = try await todayCodiUseCase.execute(jpgData: jpgData)
                self.capturedImageURL = uploadedURL
                
                // 업로드 완료 후 팝업 띄우기
                self.showCompletePopUp = true
            } catch {
                print("❌ 코디 이미지 업로드 실패: \(error.localizedDescription)")
                // 필요 시 에러 알림 처리
            }
        }
    }
    
    /// 코디 확정 후 완료 팝업을 표시
    func showCompletionPopup(imageURL: String?) {
        completedCodiImageURL = imageURL
        showCompletePopUp = true
    }
    
    /// 팝업에서 '기록하기' 버튼을 눌러 오늘 완성한 코디를 서버에 전송
//    func handlePopupRecord() {
//        Task {
//            do {
//                // 1️⃣ CodiCompositeView 캡처
//                let image = captureCompletedCodiImage()
//
//                // 2️⃣ UIImage → Base64 String
//                guard let coordinateImageUrl = image.toBase64String() else {
//                    throw NSError(domain: "Base64EncodingFail", code: 0)
//                }
//
//                self.completedCodiImageURL = coordinateImageUrl
//
//                // 3️⃣ 좌표 payload 생성
//                let containerSize: CGFloat = 260
//                let payloads = selectedCodiClothes.enumerated().map { index, cloth in
//                    let position = CodiLayoutCalculator.position(
//                        index: index,
//                        totalCount: selectedCodiClothes.count,
//                        containerSize: containerSize
//                    )
//
//                    return Payloads(
//                        clothId: cloth.clothId,
//                        locationX: position.x,
//                        locationY: position.y,
//                        ratio: 1.0,
//                        degree: 0,
//                        order: Int32(index)
//                    )
//                }
//
//                // 4️⃣ 오늘의 코디 생성 (String 그대로 전달)
//                let request = CreateTodayCoordinateRequestDTO(
//                    coordinateImageUrl: coordinateImageUrl,
//                    payloads: payloads
//                )
//
//                let result = try await todayCodiUseCase.createTodayCoordinate(request: request)
//                print("✅ 오늘 코디 생성 완료:", result.coordinateId)
//
//                showCompletePopUp = false
//                hasCodi = true
//            } catch {
//                print("❌ 코디 기록 실패:", error)
//            }
//        }
//    }
    func handlePopupRecord() {
        Task {
            do {
                guard let imageURL = self.capturedImageURL else { return }
                let containerSize: CGFloat = 260
                
                // ✅ 수정: activeCategories의 현재 '순서'를 기준으로 옷을 재수집하여 Payload 생성
                let sortedPayloads = activeCategories.enumerated().compactMap { (index, category) -> Payloads? in
                    // 해당 카테고리에서 현재 선택된 옷 찾기
                    guard let clothList = clothItemsByCategory[category.id] else { return nil }
                    let selectedIndex = selectedIndicesByCategory[category.id] ?? 0
                    let cloth = clothList.indices.contains(selectedIndex) ? clothList[selectedIndex] : clothList.first
                    
                    guard let selectedCloth = cloth else { return nil }
                    
                    // CodiLayoutCalculator 위치 계산 (현재 순서 index 반영)
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
                        order: Int32(index + 1) // ✅ 1부터 시작하는 순서 부여
                    )
                }

                let request = CreateTodayCoordinateRequestDTO(
                    coordinateImageUrl: imageURL,
                    payloads: sortedPayloads
                )

                // 🔍 [디버그 프린트 시작]
                print("""
                
                ================================[ DTO 전송 데이터 확인 ]================================
                📸 캡처된 이미지 URL: \(request.coordinateImageUrl)
                👕 포함된 옷 개수: \(request.payloads.count)개
                --------------------------------------------------------------------------------------
                """)
                
                for (index, payload) in request.payloads.enumerated() {
                    print("""
                    [옷 \(index + 1)]
                    - Cloth ID: \(payload.clothId)
                    - 위치 (X, Y): (\(String(format: "%.4f", payload.locationX)), \(String(format: "%.4f", payload.locationY)))
                    - 레이어 순서: \(payload.order)
                    """)
                }
                print("====================================================================================\n")
                // 🔍 [디버그 프린트 끝]

                // 3. 서버 전송
                let result = try await todayCodiUseCase.createTodayCoordinate(request: request)
                
                self.showCompletePopUp = false
                self.hasCodi = true
                print("✅ 오늘의 코디 저장 성공")
                
            } catch {
                print("❌ 최종 코디 저장 실패: \(error.localizedDescription)")
            }
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
                
                // 3. 데이터 로딩 후 시트 표시
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
