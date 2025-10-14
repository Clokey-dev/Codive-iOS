//
//  RecordDetailView.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import SwiftUI

// MARK: - RecordDetailView
struct RecordDetailView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: RecordDetailViewModel
    
    // MARK: - Initializer
    init(viewModel: RecordDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            CustomNavigationBar(
                title: "기록 추가",
                onBack: {
                    viewModel.dismissView()
                }
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    // Question Title
                    Text("오늘의 내 기록을 추가해볼까요?")
                        .font(.codive_title1)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    
                    // Photo Carousel
                    TabView(selection: $viewModel.currentPhotoIndex) {
                        ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.element.id) { index, photo in
                            Image(uiImage: photo.croppedImage)
                                .resizable()
                                .aspectRatio(3/4, contentMode: .fit)
                                .cornerRadius(10)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: UIScreen.main.bounds.width * 4/3 - 40)
                    .padding(.horizontal, 20)
                    
                    // Page Indicator를 위한 간격
                    Spacer()
                        .frame(height: 24)
                    
                    // Style Selection
                    CustomMultiSelectButton(
                        title: "오늘의 스타일을 선택해보세요",
                        options: viewModel.styleOptions,
                        selectedOptions: $viewModel.selectedStyles,
                        maxSelection: 3,
                        showRequiredMark: true
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Situation Selection
                    CustomMultiSelectButton(
                        title: "어떤 상황에 주로 입으시나요?",
                        options: viewModel.situationOptions,
                        selectedOptions: $viewModel.selectedSituations,
                        showRequiredMark: true
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Caption TextField
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.Codive.grayscale2)
                            
                            Text("캡션을 추가해주세요")
                                .font(.codive_body2_medium)
                                .foregroundStyle(Color.Codive.grayscale2)
                        }
                        
                        TextEditor(text: $viewModel.captionText)
                            .font(.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                            .frame(height: 158)
                            .padding(12)
                            .background(Color.Codive.grayscale7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.Codive.grayscale5, lineWidth: 1)
                            )
                            .overlay(alignment: .topLeading) {
                                if viewModel.captionText.isEmpty {
                                    Text("나만의 스타일 이야기를 채워보세요.\n#아이템과 #스타일을 자랑해보세요.")
                                        .font(.codive_body2_medium)
                                        .foregroundStyle(Color.Codive.grayscale4)
                                        .padding(.top, 20)
                                        .padding(.leading, 16)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            
            // Bottom Button
            CustomButton(
                text: "작성 완료",
                widthType: .fixed,
                action: {
                    viewModel.completeRecord()
                }
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .opacity(viewModel.isCompleteEnabled ? 1.0 : 0.5)
            .disabled(!viewModel.isCompleteEnabled)
        }
        .navigationBarHidden(true)
        .background(Color.white)
    }
}

#Preview {
    let sampleImage = UIImage(systemName: "photo")!
    let photos = [
        SelectedPhoto(id: "1", originalImage: sampleImage, order: 1),
        SelectedPhoto(id: "2", originalImage: sampleImage, order: 2),
        SelectedPhoto(id: "3", originalImage: sampleImage, order: 3)
    ]
    let router = NavigationRouter()
    let viewModel = RecordDetailViewModel(selectedPhotos: photos, navigationRouter: router)
    
    return RecordDetailView(viewModel: viewModel)
}
