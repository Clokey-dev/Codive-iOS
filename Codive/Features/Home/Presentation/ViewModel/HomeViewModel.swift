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
        loadDummyCodi()
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
    
    /// 오늘 이미 생성된 코디(더미) 데이터를 불러옴
    func loadDummyCodi() {
        codiItems = todayCodiUseCase.loadTodaysCodi()
    }
}

// MARK: - API & Async Methods
extension HomeViewModel {
    
    /// 날씨 정보를 서버에서 가져옴
//    func loadWeather(for location: CLLocation?) async {
//        do {
//            weatherData = try await fetchWeatherUseCase.execute(for: location)
//        } catch {
//            weatherErrorMessage = TextLiteral.Home.failWeather
//        }
//    }
    func loadWeather(for location: CLLocation?) async {
        do {
            // 1️⃣ 날씨 조회
            let weather = try await fetchWeatherUseCase.execute(for: location)
            self.weatherData = weather
            
            // 2️⃣ 현재 온도 추출
            let temperature = weather.currentTemp
            
            // 3️⃣ 서버에 오늘 온도 전송
            let request = PostTodayTemperatureAPIRequestDTO(
                temperature: Double(temperature)
            )
            
            try await fetchWeatherUseCase.postTodayTemp(request: request)
            
        } catch {
            weatherErrorMessage = TextLiteral.Home.failWeather
            print("Weather load or post failed:", error)
        }
    }

    /// API를 통해 활성 카테고리의 의류 아이템 리스트를 비동기로 가져옴
    func loadRecommendCategoryClothList() async {
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
    func handleConfirmCodiTap() {
        let items = activeCategories
            .sorted { $0.id < $1.id }
            .compactMap { category -> HomeClothEntity? in
                guard let clothList = clothItemsByCategory[category.id] else { return nil }
                let index = selectedIndicesByCategory[category.id] ?? 0
                return clothList.indices.contains(index) ? clothList[index] : clothList.first
            }
        
        self.selectedCodiClothes = items
        self.showCompletePopUp = true
    }
    
    /// 코디 확정 후 완료 팝업을 표시
    func showCompletionPopup(imageURL: String?) {
        completedCodiImageURL = imageURL
        showCompletePopUp = true
    }
    
    /// 팝업에서 '기록하기' 버튼을 눌러 오늘 완성한 코디를 서버에 전송
    func handlePopupRecord() {
        let containerSize: CGFloat = 260
        let payloads = selectedCodiClothes.enumerated().map { index, cloth in
            let position = CodiLayoutCalculator.position(
                index: index,
                totalCount: selectedCodiClothes.count,
                containerSize: containerSize
            )
            return CodiPayload(
                clothId: Int(cloth.clothId),
                locationX: position.x,
                locationY: position.y,
                ratio: 1.0,
                degree: 0,
                order: index
            )
        }

        let todayCodi = TodayDailyCodi(
            coordinateImageUrl: completedCodiImageURL ?? "",
            payloads: payloads
        )

        Task {
            do {
                try await todayCodiUseCase.recordTodayCodi(todayCodi)
                showCompletePopUp = false
                hasCodi = true
            } catch {
                print("Failed to record today's codi: \(error)")
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
                let list = try await addToLookBookUseCase.execute()
                self.lookBookList = list
                self.showLookBookSheet = true
            } catch {
                print("Failed to load lookbooks: \(error)")
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
}
