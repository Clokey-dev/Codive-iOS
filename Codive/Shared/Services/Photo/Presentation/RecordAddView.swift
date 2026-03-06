//
//  RecordAddView.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

// MARK: - RecordAddView
struct RecordAddView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: RecordAddViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 4)
    private let cellSize: CGFloat = (UIScreen.main.bounds.width - 9) / 4 // 3px * 3 간격 / 4개
    
    // MARK: - Initializer
    init(viewModel: RecordAddViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Navigation Bar
                CustomNavigationBar(
                    title: viewModel.navigationTitle,
                    onBack: {
                        viewModel.dismissView()
                    },
                    rightButton: .text(
                        title: TextLiteral.Common.complete,
                        isEnabled: viewModel.isCompleteEnabled
                    ) {
                        viewModel.completeSelection()
                    }
                )
                
                // Album Selector
                Button {
                    viewModel.showAlbumSheet()
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedAlbumTitle)
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.Codive.grayscale3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Photo Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 3) {
                        // 첫 번째 셀: 카메라
                        CameraCell(
                            size: CGSize(width: cellSize, height: cellSize)
                        ) {
                            viewModel.showCamera()
                        }

                        if viewModel.photos.isEmpty {
                            // 스켈레톤 셀들
                            ForEach(0..<40, id: \.self) { _ in
                                SkeletonCell(size: CGSize(width: cellSize, height: cellSize))
                            }
                        } else {
                            // 실제 사진들
                            ForEach(viewModel.photos) { photo in
                                PhotoGridCell(
                                    asset: photo.asset,
                                    isSelected: photo.isSelected,
                                    selectionOrder: photo.selectionOrder,
                                    size: CGSize(width: cellSize, height: cellSize),
                                    viewModel: viewModel
                                )
                                .onTapGesture {
                                    viewModel.togglePhotoSelection(photo)
                                }
                            }
                        }
                    }
                }

                // AI 추가 토글 (옷 추가 플로우 전용)
                if viewModel.isClothFlow {
                    aiAddToggleBar
                }
            }
            // 로딩 오버레이
            if viewModel.isCompletingSelection {
                LoadingView()
            }
        }
        .navigationBarHidden(true)
        .enableSwipeBack()
        .background(Color.white)
        .sheet(isPresented: $viewModel.isAlbumSheetPresented) {
            AlbumBottomSheet(
                albums: viewModel.albums,
                selectedAlbum: viewModel.selectedAlbum,
                viewModel: viewModel
            ) { album in
                await viewModel.selectAlbum(album)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
            CameraView { image in
                viewModel.handleCameraCapture(image: image)
            }
            .ignoresSafeArea()
        }
        .overlay {
            if viewModel.isClothInfoPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            viewModel.dismissClothInfo()
                        }
                    }

                VStack(spacing: 16) {
                    Image("Cloth_info")
                        .resizable()
                        .scaledToFit()
                        .overlay(alignment: .topTrailing) {
                            Button {
                                withAnimation {
                                    viewModel.dismissClothInfo()
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.Codive.grayscale3)
                                    .padding(12)
                            }
                        }

                    Button {
                        viewModel.isDontShowTodayChecked.toggle()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.isDontShowTodayChecked ? "checkmark.square.fill" : "square")
                                .font(.system(size: 18))
                                .foregroundStyle(viewModel.isDontShowTodayChecked ? Color.Codive.point1 : Color.Codive.grayscale4)

                            Text("오늘 다시 보지 않기")
                                .font(.codive_body2_medium)
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isClothInfoPresented)
        .task {
            await viewModel.requestAuthorization()
        }
    }

    // MARK: - AI Add Toggle Bar
    private var aiAddToggleBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI로 추가하기")
                        .font(.codive_body1_bold)
                        .foregroundStyle(Color.Codive.grayscale1)

                    Text("AI가 옷을 분류하고, 카테고리를 구별해요.")
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale4)
                }

                Spacer()

                Toggle("", isOn: $viewModel.isAIAddEnabled)
                    .labelsHidden()
                    .tint(Color.Codive.point1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.white)
    }
}
