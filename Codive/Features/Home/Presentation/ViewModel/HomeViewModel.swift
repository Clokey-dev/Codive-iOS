//
//  HomeViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import UIKit
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var hasCodi: Bool = false
    @Published var selectedIndex: Int? = 0
    @Published var showClothSelector: Bool = false
    @Published var titleFrame: CGRect = .zero
    @Published var weatherData: WeatherData?
    @Published var weatherErrorMessage: String?
    @Published var todayString: String = ""
    @Published var selectedItemID: Int?
    @Published var codiItems: [CodiItemEntity] = []
    @Published var selectedItemTags: [ClothTagEntity] = []
    @Published var activeCategories: [CategoryEntity] = []
    @Published var clothItemsByCategory: [Int: [HomeClothEntity]] = [:]
    @Published var selectedCodiClothes: [HomeClothEntity] = []
    @Published var selectedIndicesByCategory: [Int: Int] = [:]
    
    // 팝업 관련 프로퍼티 추가
    @Published var showCompletePopUp: Bool = false
    @Published var completedCodiImageURL: String?
    
    // 바텀시트 관련 프로퍼티 추가
    @Published var showLookBookSheet: Bool = false
    @Published var lookBookList: [LookBookBottomSheetEntity] = []
    
    var isAllCategoriesEmpty: Bool {
        // activeCategories에 있는 각 카테고리의 아이템 개수를 모두 더함
        let totalItemCount = activeCategories.reduce(0) { sum, category in
            sum + (clothItemsByCategory[category.id]?.count ?? 0)
        }
        return totalItemCount == 0
    }
    
    let navigationRouter: NavigationRouter
    
    // MARK: - UseCases
    private let fetchWeatherUseCase: FetchWeatherUseCase
    private let todayCodiUseCase: TodayCodiUseCase
    private let dateUseCase: DateUseCase
    private let categoryUseCase: CategoryUseCase
    private let addToLookBookUseCase: AddToLookBookUseCase
    
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
        
        loadDummyCodi()
        loadToday()
        loadActiveCategories()
    }
    
    // MARK: - Data Loading
    func loadWeather(for location: CLLocation?) async {
        do {
            let data = try await fetchWeatherUseCase.execute(for: location)
            weatherData = data
        } catch {
            print("Failed to fetch weather:", error)
            weatherErrorMessage = TextLiteral.Home.failWeather
        }
    }

    func loadActiveCategories() {
        let allCategories = categoryUseCase.loadCategories()
        print("전체 카테고리 개수: \(allCategories.count)")

        self.activeCategories = allCategories.filter { $0.itemCount > 0 }
        print("활성화된 카테고리: \(activeCategories.map { $0.title })")
        
        let clothItems = categoryUseCase.loadClothItems()
        clothItemsByCategory = Dictionary(grouping: clothItems) { $0.categoryId }
    }

    // MARK: - 새로운 API 방식 (비동기)
    func loadActiveCategoriesWithAPI() async {
        // 1. 모든 카테고리를 가져온 후 itemCount가 1 이상인 것만 필터링
        let allCategories = categoryUseCase.loadCategories()
        let filteredCategories = allCategories.filter { $0.itemCount > 0 }
        
        // 2. UI에 반영될 리스트를 필터링된 것으로 교체
        self.activeCategories = filteredCategories
        
        var allClothItems: [HomeClothEntity] = []
        
        // 3. 전체(categories)가 아닌 필터링된 리스트(filteredCategories)로 루프 실행
        for category in filteredCategories {
            do {
                let items = try await categoryUseCase.loadClothItems(
                    lastClothId: nil,
                    size: 20,
                    categoryId: Int64(category.id),
                    season: nil
                )
                allClothItems.append(contentsOf: items)
            } catch {
                print("Failed to load items for category \(category.id): \(error)")
            }
        }
        
        // 4. 결과 그룹화
        clothItemsByCategory = Dictionary(grouping: allClothItems) { $0.categoryId }
    }

    // MARK: - 특정 카테고리만 로드
    func loadClothItems(for categoryId: Int) async {
        do {
            let items = try await categoryUseCase.loadClothItems(
                lastClothId: nil,
                size: 20,
                categoryId: Int64(categoryId),
                season: nil
            )
            
            // 해당 카테고리의 아이템 업데이트
            clothItemsByCategory[categoryId] = items
        } catch {
            print("Failed to load cloth items: \(error)")
        }
    }

    // MARK: - 페이지네이션 (더 불러오기)
    func loadMoreClothItems(for categoryId: Int) async {
        guard let existingItems = clothItemsByCategory[categoryId],
              let lastItem = existingItems.last else {
            return
        }
        
        do {
            let newItems = try await categoryUseCase.loadClothItems(
                lastClothId: Int64(lastItem.id),
                size: 20,
                categoryId: Int64(categoryId),
                season: nil
            )
            
            // 기존 아이템에 추가
            clothItemsByCategory[categoryId] = existingItems + newItems
        } catch {
            print("Failed to load more items: \(error)")
        }
    }
    
    func loadDummyCodi() {
        codiItems = todayCodiUseCase.loadTodaysCodi()
    }

    func loadToday() {
        let entity = dateUseCase.getToday()
        self.todayString = entity.formattedDate
    }
    
    // MARK: - UI Actions
    func toggleClothSelector() {
        withAnimation(.spring()) {
            showClothSelector.toggle()
            
            // 셀렉터가 닫힐 때(false가 될 때) 선택된 아이템 정보 초기화
            if !showClothSelector {
                selectedItemID = nil
                selectedItemTags = []
            }
        }
    }
    
    func selectCloth(at index: Int) {
        selectedIndex = index
    }

    func selectItem(_ id: Int?) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedItemID = id
            if let id = id, let item = codiItems.first(where: { $0.id == id }) {
                // 이미지 중심 좌표(item.x)가 화면 중앙보다 오른쪽인지 왼쪽인지 판단
                // (기준을 200으로 잡거나 UIScreen.main.bounds.width / 2로 설정)
                let isImageOnRight = item.x > 200
                
                self.selectedItemTags = [
                    ClothTagEntity(
                        title: item.brandName,
                        content: item.clothName, // 또는 item.description
                        locationX: 0.5,
                        locationY: 0.5,
                        isRightSide: !isImageOnRight // 이미지가 오른쪽이면 태그는 왼쪽(false)
                    )
                ]
            } else {
                self.selectedItemTags = []
            }
        }
    }

    // 태그 위치 업데이트 (드래그 시 사용)
    func updateTagPosition(tagId: UUID, x: CGFloat, y: CGFloat, imageSize: CGSize) {
        if let index = selectedItemTags.firstIndex(where: { $0.id == tagId }) {
            selectedItemTags[index].locationX = x / imageSize.width
            selectedItemTags[index].locationY = y / imageSize.height
        }
    }
    
    func updateSelectedIndex(for categoryId: Int, index: Int) {
        selectedIndicesByCategory[categoryId] = index
    }
    
    func handleSearchTap() {}
    
    func handleNotificationTap() {}
    
    // MARK: - Navigation
    func handleCodiBoardTap() {
        navigationRouter.navigate(to: .codiBoard)
    }
    
    func handleConfirmCodiTap() {
        // 수정된 수집 로직: 저장된 인덱스를 기반으로 아이템 추출
        let items = activeCategories
            .sorted(by: { $0.id < $1.id })
            .compactMap { category -> HomeClothEntity? in
                guard let clothList = clothItemsByCategory[category.id] else { return nil }
                
                // 해당 카테고리에 저장된 인덱스가 있으면 사용, 없으면 0번째 사용
                let selectedIndex = selectedIndicesByCategory[category.id] ?? 0
                
                // 배열 범위를 벗어나지 않도록 방어 코드 추가
                if clothList.indices.contains(selectedIndex) {
                    return clothList[selectedIndex]
                } else {
                    return clothList.first
                }
            }
        
        self.selectedCodiClothes = items
        self.showCompletePopUp = true
    }
    
    func handleEditCategory() {
        navigationRouter.navigate(to: .editCategory)
    }
    
    // MARK: - Popup Actions
    func showCompletionPopup(imageURL: String?) {
        completedCodiImageURL = imageURL
        showCompletePopUp = true
    }
    
    func handlePopupRecord() {
        let containerSize: CGFloat = 260

        let payloads = selectedCodiClothes.enumerated().map { index, cloth in

            let position = CodiLayoutCalculator.position(
                index: index,
                totalCount: selectedCodiClothes.count,
                containerSize: containerSize
            )

            return CodiPayload(
                clothId: cloth.id,
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
            try await todayCodiUseCase.recordTodayCodi(todayCodi)
            showCompletePopUp = false
            hasCodi = true
        }
    }
    
    func handlePopupClose() {
        showCompletePopUp = false
        completedCodiImageURL = nil
    }
    
    // MARK: - Lifecycle
    func onAppear() {
        loadActiveCategories()
    }
    
    // MARK: - Feature Placeholders
    func rememberCodi() {}
    
    func selectEditCodi() {
        navigationRouter.navigate(to: .lookbook)
    }
    
    func addLookbook() {
        print("DEBUG: addLookbook() called") // 호출 여부 확인
        Task {
            do {
                let list = try await addToLookBookUseCase.execute()
                self.lookBookList = list
                self.showLookBookSheet = true
                print("DEBUG: showLookBookSheet set to true, list count: \(list.count)")
            } catch {
                print("DEBUG: Failed to load lookbooks: \(error)")
            }
        }
    }
    
    func selectLookBook(_ entity: LookBookBottomSheetEntity) {
        print("Selected LookBook ID: \(entity.lookbookId)")
        showLookBookSheet = false
        // 추가 성공 팝업 등을 띄우는 로직으로 이어질 수 있음
    }
    
    func sharedCodi() {}
}
