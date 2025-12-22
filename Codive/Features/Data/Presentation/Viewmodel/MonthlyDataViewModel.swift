//
//  MonthlyDataViewModel.swift
//  Codive
//
//  Created by 한태빈 on 12/19/22.
//

import SwiftUI
import Combine

class MonthlyDataViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // 1. 카테고리별 최애 아이템 (상의, 바지, 신발 등)
    @Published var favoriteCategories: [CategoryFavoriteItem] = []
    
    // 2. 옷장 아이템 통계 (막대 그래프용)
    @Published var itemStats: [ItemUsageStat] = []
    
    // 3. 옷장 활용도 체크 (도넛 차트용)
    @Published var wardrobeUsage: WardrobeUsageStat = WardrobeUsageStat(totalCount: 0, wornCount: 0)
    
    @Published var dateRangeString: String = "2025/08/08 ~ 2025/09/08"
    @Published var reportTitle: String = "9월 옷장 리포트"

    init() {
        fetchData()
    }
    
    // MARK: - Data Fetching (Mock)
    
    func fetchData() {
        // API 연동 전 더미 데이터 세팅
        
        // 1. 카테고리별 최애 아이템
        self.favoriteCategories = [
            CategoryFavoriteItem(
                categoryName: "상의",
                items: [
                    DonutSegment(value: 5, color: Color.Codive.point1, payload: "맨투맨"),
                    DonutSegment(value: 3, color: Color.Codive.point2, payload: "후드티"),
                    DonutSegment(value: 2, color: Color.Codive.point3, payload: "셔츠"),
                    DonutSegment(value: 2, color: Color.Codive.grayscale5, payload: "기타")
                ]
            ),
            CategoryFavoriteItem(
                categoryName: "바지",
                items: [
                    DonutSegment(value: 8, color: Color.Codive.point1, payload: "청바지"),
                    DonutSegment(value: 4, color: Color.Codive.point2, payload: "슬랙스"),
                    DonutSegment(value: 1, color: Color.Codive.grayscale5, payload: "기타")
                ]
            ),
            CategoryFavoriteItem(
                categoryName: "신발",
                items: [
                    DonutSegment(value: 6, color: Color.Codive.point1, payload: "운동화"),
                    DonutSegment(value: 2, color: Color.Codive.point2, payload: "구두"),
                    DonutSegment(value: 1, color: Color.Codive.point3, payload: "슬리퍼")
                ]
            )
        ]
        
        // 2. 옷장 아이템 통계
        self.itemStats = [
            ItemUsageStat(itemName: "맨투맨", usageCount: 20),
            ItemUsageStat(itemName: "원피스", usageCount: 15),
            ItemUsageStat(itemName: "니트", usageCount: 12),
            ItemUsageStat(itemName: "후드티", usageCount: 8),
            ItemUsageStat(itemName: "레깅스", usageCount: 5)
        ]
        
        // 3. 옷장 활용도 체크
        self.wardrobeUsage = WardrobeUsageStat(totalCount: 20, wornCount: 8)
    }
}
