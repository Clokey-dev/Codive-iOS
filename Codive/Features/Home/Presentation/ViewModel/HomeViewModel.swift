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
    
    @Published var isEditingExistingCodi: Bool = false
    @Published var isConfirmLoading: Bool = false
    @Published var isOverflowMenuExpanded: Bool = false
    
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
    @Published var needsScrollReset: Bool = false
    
    // MARK: - Dependencies
    
    let navigationRouter: NavigationRouter
    private let fetchWeatherUseCase: FetchWeatherUseCase
    internal let todayCodiUseCase: TodayCodiUseCase
    private let dateUseCase: DateUseCase
    private let categoryUseCase: CategoryUseCase
    internal let addToLookBookUseCase: AddToLookBookUseCase
    
    var isAllCategoriesEmpty: Bool {
        let totalItemCount = activeCategories.reduce(0) { sum, category in
            sum + (clothItemsByCategory[category.id]?.count ?? 0)
        }
        return totalItemCount == 0
    }
    
    var currentSeasons: Set<Season> {
        let temp = Int(weatherData?.currentTemp ?? 20)
        if temp >= 18 { return [.summer] } else if temp >= 7 { return [.spring, .fall] } else { return [.winter] }
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
    
    func onAppear() {
        loadActiveCategories()
        fetchTodayCodiData()
    }

    func navigateToAddCloth() {
        navigationRouter.navigate(to: .clothPhotoSelect)
    }
}

extension HomeViewModel {
    func loadInitialData() {
        loadToday()
        loadActiveCategories()
    }
    
    func loadToday() {
        let entity = dateUseCase.getToday()
        self.todayString = entity.formattedDate
    }
    
    func loadActiveCategories() {
        let allCategories = categoryUseCase.loadCategories()
        self.activeCategories = allCategories.filter { $0.itemCount > 0 }
    }
    
    func loadWeather(for location: CLLocation?) async {
        do {
            let weather = try await fetchWeatherUseCase.execute(for: location)
            self.weatherData = weather
            
            let temperature = weather.currentTemp
            
            let targetSeasons = determineSeasons(from: temperature)
            await loadRecommendCategoryClothList(seasons: targetSeasons)
            
            let request = PostTodayTemperatureAPIRequestDTO(
                temperature: Double(temperature)
            )
            try await fetchWeatherUseCase.postTodayTemp(request: request)
        } catch {
            weatherErrorMessage = TextLiteral.Home.failWeather
            #if DEBUG
            print("[Home] Weather load or post failed:", error)
            #endif
        }
    }
    
    internal func determineSeasons(from temperature: Int) -> Set<Season> {
        if temperature >= 30 {
            return [.summer]
        } else if temperature >= 10 {
            return [.spring, .fall]
        } else {
            return [.winter]
        }
    }
}

extension HomeViewModel {
    func loadRecommendCategoryClothList(seasons: Set<Season>) async {
        let allCategories = categoryUseCase.loadCategories()
        let filteredCategories = allCategories.filter { $0.itemCount > 0 }

        #if DEBUG
        print("[Home] ========== 카테고리별 옷 로드 시작 ==========")
        print("[Home] 전달된 계절: \(seasons.map { $0.rawValue })")
        print("[Home] 활성 카테고리: \(filteredCategories.map { "\($0.title)(id:\($0.id), count:\($0.itemCount))" })")
        #endif

        self.activeCategories = filteredCategories

        var resultMap: [Int: [HomeClothEntity]] = [:]

        for category in filteredCategories {
            do {
                let result = try await categoryUseCase.loadClothItems(
                    lastClothId: nil,
                    size: 10,
                    categoryId: Int64(category.id),
                    season: seasons
                )
                let sorted = result.content.sorted { $0.clothId < $1.clothId }
                resultMap[category.id] = sorted

                #if DEBUG
                print("[Home] 카테고리 '\(category.title)' (id:\(category.id)) → API 결과 \(sorted.count)개")
                for item in sorted {
                    print("[Home]   - clothId: \(item.clothId), imageUrl: \(item.imageUrl)")
                }
                #endif
            } catch {
                #if DEBUG
                print("[Home] 카테고리 '\(category.title)' (id:\(category.id)) → 로드 실패: \(error)")
                #endif
                resultMap[category.id] = []
            }
        }

        #if DEBUG
        print("[Home] ========== 카테고리별 옷 로드 완료 ==========")
        #endif

        self.clothItemsByCategory = resultMap
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
        activeCategories.move(fromOffsets: source, toOffset: destination)
        
        // 순서 변경을 로컬에 저장하려면 categoryUseCase를 통해 저장
        // categoryUseCase.saveCategoryOrder(activeCategories)
    }
    
    func updateSelectedIndex(for categoryId: Int, index: Int) {
        selectedIndicesByCategory[categoryId] = index
    }
}

extension HomeViewModel {
    func refreshAfterCategoryEdit() {
        loadActiveCategories()
        needsScrollReset = true
        Task {
            await loadRecommendCategoryClothList(seasons: currentSeasons)
        }
    }

    func handleEditCategory() {
        navigationRouter.navigate(to: .editCategory)
    }
    
    func handleCodiBoardTap() {
        let containerSize: CGFloat = 260
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
    
    func handleConfirmCodiTap() {
        let items = activeCategories
            .compactMap { category -> HomeClothEntity? in
                guard let clothList = clothItemsByCategory[category.id] else { return nil }
                let index = selectedIndicesByCategory[category.id] ?? 0
                return clothList.indices.contains(index) ? clothList[index] : clothList.first
            }
        
        self.selectedCodiClothes = items
        self.isConfirmLoading = true

        Task {
            defer { self.isConfirmLoading = false }

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
                .background(Color.Codive.grayscale7)

            let renderer = ImageRenderer(content: captureView)
            renderer.isOpaque = true
            renderer.scale = UIScreen.main.scale

            guard let uiImage = renderer.uiImage else {
                return
            }

            guard let jpgData = uiImage.jpegData(compressionQuality: 0.8) else { return }

            do {
                let uploadedURL = try await todayCodiUseCase.execute(jpgData: jpgData)

                self.capturedImageURL = uploadedURL
                self.showCompletePopUp = true
            } catch {
                #if DEBUG
                print("[Home] 서버 에러: \(error.localizedDescription)")
                #endif
            }
        }
    }
}
