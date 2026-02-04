//
//  HomeViewModel.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI
import Combine
import CoreLocation

struct TodayCodiTransferData {
    let images: [DraggableImageEntity]
}

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
//    func handleCodiBoardTap() {
//        navigationRouter.navigate(to: .codiBoard)
//    }
    // HomeViewModel.swift

    // HomeViewModel.swift

    func handleCodiBoardTap() {
        let containerSize: CGFloat = 260
        // 보드 중앙 기준 좌표계로 변환하기 위한 오프셋
        let centerOffset = containerSize / 2
        
        let transferImages = activeCategories.enumerated().compactMap { (index, category) -> DraggableImageEntity? in
            guard let clothList = clothItemsByCategory[category.id],
                  let selectedIndex = selectedIndicesByCategory[category.id] else {
                return nil
            }
            
            let cloth = clothList.indices.contains(selectedIndex) ? clothList[selectedIndex] : clothList.first
            guard let selectedCloth = cloth else { return nil }
            
            // 1. CodiLayoutCalculator가 주는 절대 좌표 (0~260 범위)
            let rawPos = CodiLayoutCalculator.position(
                index: index,
                totalCount: activeCategories.count,
                containerSize: containerSize
            )
            
            // 2. ZoomRotateDragView의 .offset 방식에 맞게 중앙(0,0) 기준 상대 좌표로 변환
            let relativePos = CGPoint(
                x: rawPos.x - centerOffset,
                y: rawPos.y - centerOffset
            )
            
            return DraggableImageEntity(
                id: selectedCloth.clothId,
                name: selectedCloth.imageUrl,
                position: relativePos,
                scale: 0.7, // ✅ 크기를 70%로 줄여서 전달
                rotation: 0
            )
        }
        
        let data = TodayCodiTransferData(images: transferImages)
        
        print("""
        [보내는 쪽: HomeViewModel] 🚀 데이터 전송 (크기 70% 적용)
        - 전송 아이템 개수: \(data.images.count)개
        - 적용 배율: \(data.images.first?.scale ?? 0)
        """)
        
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
    // HomeViewModel.swift 내 handleConfirmCodiTap 수정

    func handleConfirmCodiTap() {
        let items = activeCategories
            .compactMap { category -> HomeClothEntity? in
                guard let clothList = clothItemsByCategory[category.id] else { return nil }
                let index = selectedIndicesByCategory[category.id] ?? 0
                return clothList.indices.contains(index) ? clothList[index] : clothList.first
            }
        
        self.selectedCodiClothes = items
        print("📸 [Home Capture] 1단계: 이미지 다운로드 시작 (대상: \(items.count)개)")
        
        Task {
            // 1. 모든 이미지를 UIImage로 병렬 다운로드
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
            
            print("✅ [Home Capture] 2단계: 이미지 다운로드 완료 (\(loadedImages.count)/\(items.count))")

            // 2. 다운로드된 이미지가 담긴 뷰 생성
            let captureView = CodiCompositeView(clothes: items, loadedImages: loadedImages)
                .frame(width: 260, height: 260)
            
            // 3. 캡처 실행 (이미 이미지가 있으므로 대기 시간 필요 없음)
            let renderer = ImageRenderer(content: captureView)
            renderer.scale = UIScreen.main.scale
            
            guard let uiImage = renderer.uiImage else {
                print("❌ [Home Capture] UIImage 생성 실패")
                return
            }
            
            print("✅ [Home Capture] 3단계: 이미지 캡처 성공")
            
            guard let jpgData = uiImage.jpegData(compressionQuality: 0.8) else { return }
            
            do {
                print("📡 [Home Upload] 4단계: 서버 업로드 중...")
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

    // ✅ 이미지 다운로드 헬퍼 메서드 추가
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
                // 1. 공통 이미지 URL 확인
                guard let imageURL = self.capturedImageURL else {
                    print("⚠️ [Error] 이미지 URL이 없습니다.")
                    return
                }
                
                // 2. 데이터 소스 구분 (보드 편집본 vs 홈 리스트 조합)
                let finalPayloads: [Payloads]
                
                if !boardPayloads.isEmpty {
                    // CASE A: 코디보드에서 편집하여 넘어온 경우
                    finalPayloads = boardPayloads
                    print("📝 [Case] 코디보드 편집 데이터로 기록을 시작합니다.")
                } else {
                    // CASE B: 홈 화면에서 바로 '결정하기'를 누른 경우
                    finalPayloads = createPayloadsFromCurrentList()
                    print("📝 [Case] 홈 화면 리스트 조합으로 기록을 시작합니다.")
                }

                // 3. 서버 전송용 DTO 생성
                let request = CreateTodayCoordinateRequestDTO(
                    coordinateImageUrl: imageURL,
                    payloads: finalPayloads
                )

                // 5. 서버 전송 API 호출
                let result = try await todayCodiUseCase.createTodayCoordinate(request: request)
                
                // 6. UI 상태 초기화 및 성공 처리
                await MainActor.run {
                    self.showCompletePopUp = false
                    self.hasCodi = true
                    self.boardPayloads = [] // 다음 기록을 위해 초기화
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
        return activeCategories.enumerated().compactMap { (index, category) -> Payloads? in
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
