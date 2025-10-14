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
    @State private var isExpanded: Bool = false
    
    private let collapsedHeight: CGFloat = 250
    
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
                        title: TextLiteral.Add.photoTagTitle,
                        onBack: {
                            viewModel.dismissView()
                        },
                        rightButton: .text(
                            title: TextLiteral.Add.photoTagAnimationText,
                            isEnabled: viewModel.isCompleteEnabled
                        ) {
                            viewModel.completeTagging()
                        }
                    )
                    
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
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
        .ignoresSafeArea(.all, edges: .bottom)
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
                .onTapGesture {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }
            
            // Content Area (비어있음 - 나중에 구현)
            ScrollView {
                VStack {
                    ForEach(0..<20) { index in
                        Text("Content \(index)")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .frame(
            width: geometry.size.width,
            height: isExpanded ? geometry.size.height * 0.7 : collapsedHeight
        )
        .background(Color.white)
        .customCornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let dragDistance = value.translation.height
                    
                    withAnimation(.spring()) {
                        if dragDistance < -50 {
                            // 위로 스와이프 - 확장
                            isExpanded = true
                        } else if dragDistance > 50 {
                            // 아래로 스와이프 - 축소
                            isExpanded = false
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
