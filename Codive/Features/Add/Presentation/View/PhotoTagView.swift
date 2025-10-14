//
//  PhotoTagView.swift
//  Codive
//
//  Created by 황상환 on 10/14/25.
//

import SwiftUI

// MARK: - PhotoTagView
struct PhotoTagView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: PhotoTagViewModel
    @State private var bottomSheetOffset: CGFloat = 0
    
    private let minBottomSheetHeight: CGFloat = 300
    private let maxBottomSheetHeight: CGFloat = 600
    
    // MARK: - Initializer
    init(viewModel: PhotoTagViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main Content
                VStack(spacing: 0) {
                    // Navigation Bar
                    CustomNavigationBar(
                        title: "태그하기",
                        onBack: {
                            viewModel.dismissView()
                        },
                        rightButton: .text(
                            title: "완료",
                            isEnabled: viewModel.isCompleteEnabled
                        ) {
                            viewModel.completeTagging()
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // Photo
                    Image(uiImage: viewModel.currentPhoto.croppedImage)
                        .resizable()
                        .aspectRatio(3/4, contentMode: .fit)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                
                // Bottom Sheet
                bottomSheet(geometry: geometry)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - View Components
private extension PhotoTagView {
    
    @ViewBuilder
    func bottomSheet(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Handle Bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.Codive.grayscale5)
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Content Area (비어있음 - 나중에 구현)
            Spacer()
        }
        .frame(height: minBottomSheetHeight + max(0, -bottomSheetOffset))
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .customCornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .offset(y: bottomSheetOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation.height
                    // 위로만 드래그 가능 (음수 값만)
                    if translation < 0 {
                        let maxDrag = maxBottomSheetHeight - minBottomSheetHeight
                        bottomSheetOffset = max(translation, -maxDrag)
                    } else {
                        bottomSheetOffset = 0
                    }
                }
                .onEnded { value in
                    let translation = value.translation.height
                    let velocity = value.predictedEndTranslation.height
                    
                    withAnimation(.spring()) {
                        if velocity < -200 || translation < -100 {
                            // 위로 스와이프 - 전체 확장
                            bottomSheetOffset = -(maxBottomSheetHeight - minBottomSheetHeight)
                        } else {
                            // 기본 위치로 복귀
                            bottomSheetOffset = 0
                        }
                    }
                }
        )
    }
}

// MARK: - Custom Corner Radius
extension View {
    func customCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CustomRoundedCorner(radius: radius, corners: corners))
    }
}

struct CustomRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    let sampleImage = UIImage(systemName: "photo")!
    let photo = SelectedPhoto(id: "1", originalImage: sampleImage, order: 1)
    let router = NavigationRouter()
    let viewModel = PhotoTagViewModel(photo: photo, allPhotos: [photo], navigationRouter: router)
    
    return PhotoTagView(viewModel: viewModel)
}
