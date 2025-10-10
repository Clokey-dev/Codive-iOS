//
//  CustomTestView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

struct CustomTestView: View {
    // MARK: - State Properties
    @State private var selectedItemIndex: Int = 0
    @State private var textField1Text: String = ""
    @State private var textField2Text: String = ""
    @State private var textField2WithButton: String = "dksdbs12"
    @State private var textField2Error: String = "집에가고싶어요"
    
    // MultiSelect State
    @State private var selectedSeasons: Set<String> = ["봄", "여름"]
    @State private var selectedStyles: Set<String> = ["캐주얼"]
    @State private var selectedColors: Set<String> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // MARK: - CustomAIRecommendationView
                CustomAIRecommendationView(
                    items: [
                        ClothingItem(
                            imageName: "sample_clothes1",
                            category: "상의",
                            subcategory: "블라우스",
                            season: "봄",
                            name: "핑크 블라우스",
                            brand: "",
                            purchaseUrl: ""
                        ),
                        ClothingItem(
                            imageName: "sample_clothes2",
                            category: "상의",
                            subcategory: "반팔티",
                            season: "봄, 여름, 가을",
                            name: "블랙 티셔츠",
                            brand: "",
                            purchaseUrl: ""
                        ),
                        ClothingItem(
                            imageName: "sample_clothes3",
                            category: "아우터",
                            subcategory: "점퍼/바람막이",
                            season: "봄, 가을",
                            name: "민트 셔츠 재킷",
                            brand: "",
                            purchaseUrl: ""
                        )
                    ],
                    selectedItemIndex: $selectedItemIndex,
                    onCategoryTap: {
                        print("카테고리 선택")
                    },
                    onSeasonTap: {
                        print("계절 선택")
                    }
                )
                
                Divider()
                    .padding(.horizontal, 20)
                
                // MARK: - CustomMultiSelectButton Examples
                VStack(alignment: .leading, spacing: 16) {
                    Text("CustomMultiSelectButton 예제")
                        .font(.codive_title1)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 24) {
                        // 계절 선택 (최대 4개)
                        CustomMultiSelectButton(
                            title: "계절",
                            options: ["봄", "여름", "가을", "겨울"],
                            selectedOptions: $selectedSeasons,
                            maxSelection: 4,
                            showRequiredMark: true
                        )
                        
                        // 스타일 선택 (최대 3개)
                        CustomMultiSelectButton(
                            title: "스타일",
                            options: ["캐주얼", "포멀", "스트릿", "빈티지", "미니멀", "스포츠"],
                            selectedOptions: $selectedStyles,
                            maxSelection: 3,
                            showRequiredMark: true
                        )
                        
                        // 색상 선택 (제한 없음)
                        CustomMultiSelectButton(
                            title: "색상",
                            options: ["블랙", "화이트", "그레이", "베이지", "네이비", "브라운", "레드", "블루"],
                            selectedOptions: $selectedColors,
                            showRequiredMark: false
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // MARK: - CustomTagView Examples
                VStack(alignment: .leading, spacing: 16) {
                    Text("CustomTagView 예제")
                        .font(.codive_title1)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        // Basic Tags
                        HStack(spacing: 12) {
                            CustomTagView(type: .basic(
                                title: "brand",
                                content: "texttexttexttexttexttext..."
                            ))
                            
                            CustomTagView(type: .basic(
                                title: "색상",
                                content: "블랙, 화이트"
                            ))
                        }
                        
                        // Closable Tags
                        HStack(spacing: 12) {
                            CustomTagView(type: .closable(
                                title: "Typeservice",
                                content: "Layered Henry Neck Long Slee..."
                            ) {
                                print("Close 버튼 탭")
                            })
                            
                            CustomTagView(type: .closable(
                                title: "카테고리",
                                content: "상의 > 반팔티"
                            ) {
                                print("카테고리 닫기")
                            })
                        }

                        // Navigable Tags
                        VStack(spacing: 12) {
                            CustomTagView(type: .navigable(
                                title: "Typeservice",
                                content: "Layered Henry Neck Long Slee..."
                            ) {
                                print("Navigate 탭")
                            })
                            
                            CustomTagView(type: .navigable(
                                title: "구매처",
                                content: "www.example.com/product"
                            ) {
                                print("구매처 이동")
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .background(Color.Codive.grayscale1)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // MARK: - CustomTextField1 Examples
                VStack(alignment: .leading, spacing: 16) {
                    Text("CustomTextField1 예제")
                        .font(.codive_title1)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 24) {
                        CustomTextField1(
                            title: "계절",
                            placeholder: "봄",
                            text: $textField1Text
                        )
                        
                        CustomTextField1(
                            title: "옷 이름",
                            placeholder: "옷 이름을 입력해주세요.",
                            text: .constant("")
                        )
                        
                        CustomTextField1(
                            title: "브랜드",
                            placeholder: "브랜드를 입력해주세요.",
                            text: .constant("나이키")
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                Divider()
                    .padding(.horizontal, 20)
                
                // MARK: - CustomTextField2 Examples
                VStack(alignment: .leading, spacing: 16) {
                    Text("CustomTextField2 예제")
                        .font(.codive_title1)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 32) {
                        // 기본 형태 (버튼 없음)
                        CustomTextField2(
                            title: "닉네임",
                            placeholder: "집에가자",
                            text: $textField2Text,
                            showRequiredMark: true,
                            helperText: "사용 가능한 닉네임 입니다."
                        )
                        
                        // 버튼 + 안내문구
                        CustomTextField2(
                            title: "아이디",
                            placeholder: "",
                            text: $textField2WithButton,
                            showRequiredMark: true,
                            buttonTitle: "중복 확인",
                            onButtonTap: {
                                print("중복 확인 버튼 탭")
                            },
                            helperText: "사용 가능한 아이디 입니다."
                        )
                        
                        // 에러 상태
                        CustomTextField2(
                            title: "닉네임",
                            placeholder: "",
                            text: $textField2Error,
                            showRequiredMark: true,
                            helperText: "6글자 이내로 입력해주세요.",
                            helperTextColor: Color.Codive.point1
                        )
                        
                        // 한줄소개 (버튼 없음, 필수 아님)
                        CustomTextField2(
                            title: "한줄소개",
                            placeholder: "20자 이내로 나를 소개 해보세요",
                            text: .constant("")
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical, 20)
            .background(Color.white)
        }
        .background(Color.Codive.grayscale7)
    }
}

#Preview {
    CustomTestView()
}
