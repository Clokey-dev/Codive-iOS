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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                CustomNavigationBar(title: "기록 추가") {
                    viewModel.dismissView()
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        Text("오늘의 내 기록을 추가해볼까요?")
                            .font(.codive_title1)
                            .foregroundStyle(Color.Codive.grayscale1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 16)
                        
                        photoCarouselSection(geometry: geometry)
                        multiSelectSection()
                        captionSection()
                    }
                }
                
                bottomButton()
            }
            .navigationBarHidden(true)
            .background(Color.white)
        }
    }
}

// MARK: - View Components
private extension RecordDetailView {
    
    @ViewBuilder
    func photoCarouselSection(geometry: GeometryProxy) -> some View {
        let imageWidth = max(geometry.size.width - 40, 0)
        let imageHeight = imageWidth * 4 / 3
        
        VStack(spacing: 0) {
            TabView(selection: $viewModel.currentPhotoIndex) {
                ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.element.id) { index, photo in
                    Image(uiImage: photo.croppedImage)
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fit)
                        .cornerRadius(10)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: max(imageHeight, 1))
            .padding(.horizontal, 20)
            
            HStack(spacing: 6) {
                ForEach(0..<viewModel.selectedPhotos.count, id: \.self) { index in
                    Circle()
                        .fill(index == viewModel.currentPhotoIndex ? Color.Codive.grayscale1 : Color.Codive.grayscale5)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }
    
    @ViewBuilder
    func multiSelectSection() -> some View {
        VStack(spacing: 24) {
            CustomMultiSelectButton(
                title: "오늘의 스타일을 선택해보세요",
                options: viewModel.styleOptions,
                selectedOptions: $viewModel.selectedStyles,
                maxSelection: 3,
                showRequiredMark: true
            )
            
            CustomMultiSelectButton(
                title: "어떤 상황에 주로 입으시나요?",
                options: viewModel.situationOptions,
                selectedOptions: $viewModel.selectedSituations,
                showRequiredMark: true
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    @ViewBuilder
    func captionSection() -> some View {
        TextEditor(text: $viewModel.captionText)
            .font(.codive_body2_medium)
            .foregroundStyle(Color.Codive.grayscale1)
            .frame(height: 158)
            .padding(12)
            .background(Color.Codive.grayscale7)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Codive.grayscale5, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                if viewModel.captionText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.Codive.grayscale1)
                            
                            Text("캡션을 추가해주세요")
                                .font(.codive_body1_medium)
                                .foregroundStyle(Color.Codive.grayscale1)
                        }
                        
                        Text("나만의 스타일 이야기를 채워보세요.\n#아이템과 #스타일을 자랑해보세요.")
                            .font(.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale4)
                    }
                    .padding(.top, 20)
                    .padding(.leading, 16)
                    .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
    }
    
    @ViewBuilder
    func bottomButton() -> some View {
        CustomButton(text: "작성 완료", widthType: .fixed) {
            viewModel.completeRecord()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .opacity(viewModel.isCompleteEnabled ? 1.0 : 0.5)
        .disabled(!viewModel.isCompleteEnabled)
    }
}

// MARK: - Preview
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
