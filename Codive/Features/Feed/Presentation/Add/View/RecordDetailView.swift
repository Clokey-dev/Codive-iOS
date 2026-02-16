//
//  RecordDetailView.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import SwiftUI
import UIKit

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
                CustomNavigationBar(
                    title: TextLiteral.Add.recordTitle,
                    onBack: { viewModel.dismissView() },
                    rightButton: .text(
                        title: "완료",
                        isEnabled: viewModel.isCompleteEnabled && !viewModel.isLoading,
                        action: viewModel.completeRecord
                    )
                )

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            Text(TextLiteral.Add.recordDetailQuestion)
                                .font(.codive_title1)
                                .foregroundStyle(Color.Codive.grayscale1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 16)

                            photoCarouselSection(geometry: geometry)
                            multiSelectSection()
                            captionSection()
                                .id("captionSection")
                                .onReceive(NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification)) { _ in
                                    withAnimation {
                                        scrollProxy.scrollTo("captionSection", anchor: .bottom)
                                    }
                                }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .background(Color.white)
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
            .alert(TextLiteral.Add.exitAlertTitle, isPresented: $viewModel.showExitAlert) {
                Button(TextLiteral.Add.exitAlertLeave, role: .destructive) {
                    viewModel.confirmExit()
                }
                Button(TextLiteral.Common.cancel, role: .cancel) {}
            } message: {
                Text(TextLiteral.Add.exitAlertMessage)
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .overlay(alignment: .center) {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
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
                    if photo.clothTags.isEmpty {
                        // 태그가 없으면 애니메이션 카드
                        AnimatedPhotoCard(photo: photo) {
                            viewModel.navigateToPhotoTag()
                        }
                        .tag(index)
                    } else {
                        // 태그가 있으면 태그 표시
                        ZStack {
                            TaggableImageView(
                                image: photo.croppedImage,
                                tags: $viewModel.selectedPhotos[index].clothTags,
                                selectedTagId: nil,
                                onTagRemove: { _ in },
                                isDraggable: false
                            )
                            .aspectRatio(3/4, contentMode: .fit)
                            
                            // 탭해서 태그 편집으로 이동
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.navigateToPhotoTag()
                                }
                        }
                        .tag(index)
                    }
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
                title: TextLiteral.Add.recordDetailStyleTitle,
                options: viewModel.styleOptions,
                selectedOptions: $viewModel.selectedStyles,
                maxSelection: 3,
                showRequiredMark: true
            )
            
            CustomMultiSelectButton(
                title: TextLiteral.Add.recordDetailSituationTitle,
                options: viewModel.situationOptions,
                selectedOptions: $viewModel.selectedSituations,
                showRequiredMark: true
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    // TODO: 플레이스 홀더 문구 수정 필요
    @ViewBuilder
    func captionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // HashtagTextEditor
            HashtagTextEditor(
                text: $viewModel.captionText,
                hashtagColor: UIColor(Color.Codive.point1),
                font: UIFont.systemFont(ofSize: 15, weight: .medium),
                textColor: UIColor.black,
                placeholder: TextLiteral.Add.recordDetailCaptionPlaceholder,
                placeholderColor: UIColor(Color.Codive.grayscale4)
            )
            .frame(height: 158)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.Codive.grayscale5, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}
