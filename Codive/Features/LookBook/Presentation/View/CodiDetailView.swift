//
//  CodiDetailView.swift
//  Codive
//
//  Created by 한금준 on 12/18/25.
//

import SwiftUI

struct CodiDetailView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: CodiDetailViewModel
    
    // MARK: - Initializer
    init(viewModel: CodiDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                topBar
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        codiDisplayArea(width: geometry.size.width)
                        
                        if viewModel.showClothSelector {
                            clothSelector
                        }
                        
                        infoSection
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white)
        .onAppear {
            viewModel.fetchCoordinatePreview()
            viewModel.fetchCoordinateDetail()
        }
        .alert(TextLiteral.LookBook.codiDelete, isPresented: $viewModel.showDeleteAlert) {
            deleteAlertButtons
        } message: {
            Text(TextLiteral.LookBook.alertDeleteTitle)
        }
    }
}

// MARK: - View Components
private extension CodiDetailView {
    
    /// 상단 네비게이션 및 메뉴 바
    var topBar: some View {
        CustomNavigationBar(
            title: viewModel.coordinatePreview?.coordinateName ?? TextLiteral.LookBook.codiDetail,
            onBack: viewModel.handleBackTap,
            rightButton: .overflow(
                menuType: .closet,
                menuActions: [
                    { viewModel.navigateToEditCodi() },
                    { viewModel.requestDelete() }
                ]
            )
        )
        .zIndex(10)
        .padding(.leading, 10)
    }
    
    /// 코디 이미지 및 배경 캔버스 영역
    func codiDisplayArea(width: CGFloat) -> some View {
        let boardSize = max(width - 40, 0)
        
        return ZStack(alignment: .bottomLeading) {
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .frame(width: boardSize, height: boardSize)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
                .padding(.horizontal, 20)
            
            GeometryReader { geo in
                ZStack {
                    if let detail = viewModel.coordinatePreview {
                        RemoteFillImage(urlString: detail.imageUrl)
                            .frame(
                                width: geo.size.width,
                                height: geo.size.height
                            )
                    }
                    
                    if viewModel.showClothSelector {
                        tagOverlayLayer(
                            imageSize: geo.size
                        )
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .position(x: width / 2, y: boardSize / 2)
            
            tagToggleButton
        }
    }
    
    /// 코디에 포함된 개별 의류 선택기
    var clothSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.clothItems.enumerated()), id: \.element.id) { index, item in
                        clothItemCell(at: index, item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    /// 코디 이름 및 메모 정보 섹션
    @ViewBuilder
    var infoSection: some View {
        if let detail = viewModel.coordinatePreview {
            CodiInfoSection(name: detail.coordinateName, memo: detail.coordinateMemo)
        }
    }
    
    @ViewBuilder
    func tagOverlayLayer(imageSize: CGSize) -> some View {
        if let detail = viewModel.selectedDetail {
            // detail.locationX/Y는 0.0 ~ 1.0 사이의 비율 값이라고 가정합니다.
            tagView(
                detail: detail,
                imageSize: imageSize
            )
            .transition(.scale.combined(with: .opacity)) // 나타날 때 효과
        }
    }
    
    func tagView(
        detail: CoordinateDetailEntity,
        imageSize: CGSize
    ) -> some View {
        CustomTagView(
            type: .basic(
                title: detail.brand,
                content: detail.name,
                //                onTap: { print("\(detail.name) 클릭됨") }
            )
        )
        .position(
            x: imageSize.width * CGFloat(detail.locationX),
            y: imageSize.height * CGFloat(detail.locationY)
        )
        .zIndex(Double(detail.order) + 100) // 다른 요소보다 위에 오도록
    }
}

// MARK: - Subviews
private extension CodiDetailView {
    
    /// 태그 토글 버튼
    var tagToggleButton: some View {
        Button(action: viewModel.toggleClothSelector) {
            Image("ic_tag")
                .resizable()
                .frame(width: 28, height: 28)
        }
        .padding(.leading, 36)
        .padding(.bottom, 16)
    }
    
    func clothItemCell(at index: Int, item: CodiItem) -> some View {
        ZStack {
            // ✅ URL 이미지 로딩
            AsyncImage(url: URL(string: item.imageName)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                case .failure(_):
                    Image(systemName: "photo") // 로드 실패 시 아이콘
                        .foregroundColor(.gray)
                @unknown default:
                    Color.Codive.main6.opacity(0.1)
                }
            }
            .frame(width: 68, height: 68)
            .clipped()
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(viewModel.selectedIndex == index ? Color.Codive.main3 : Color.clear, lineWidth: 2)
            )
        }
        .frame(width: 72, height: 72)
        .onTapGesture {
            withAnimation(.spring()) {
                viewModel.selectCloth(at: index)
            }
        }
    }
    
    /// 삭제 확인 알럿 버튼
    @ViewBuilder
    var deleteAlertButtons: some View {
        Button(TextLiteral.Common.cancel, role: .cancel) { }
        Button(TextLiteral.Common.delete, role: .destructive) {
            viewModel.deleteCodi()
        }
    }
}

// MARK: - Supporting Views (Reusable)

/// 코디 정보 표시 (이름/메모)
private struct CodiInfoSection: View {
    let name: String
    let memo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(TextLiteral.LookBook.codiNameTitle).font(.headline)
                Text(name).font(.body)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(TextLiteral.LookBook.memoTitle).font(.headline)
                Text(memo).font(.body).foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}

/// 원격 이미지 로드 뷰
private struct RemoteFillImage: View {
    let urlString: String
    
    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
}
