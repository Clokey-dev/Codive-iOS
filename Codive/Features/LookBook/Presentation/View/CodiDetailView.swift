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
            viewModel.fetchCodiDetail()
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
            title: viewModel.codiDetail?.name ?? TextLiteral.LookBook.codiDetail,
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
        .padding(.leading, 15)
    }
    
    /// 코디 이미지 및 배경 캔버스 영역
    func codiDisplayArea(width: CGFloat) -> some View {
        let boardSize = max(width - 40, 0)
        
        return ZStack(alignment: .bottomLeading) {
            // 배경 프레임
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .frame(width: boardSize, height: boardSize)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                }
                .padding(.horizontal, 20)
            
            // 코디 메인 이미지
            if let detail = viewModel.codiDetail {
                RemoteFillImage(urlString: detail.imageURL)
                    .frame(width: width - 80, height: width - 80)
                    .position(x: width / 2, y: boardSize / 2)
            }
            
            // 태그 정보 토글 버튼
            tagToggleButton
        }
    }
    
    /// 코디에 포함된 개별 의류 선택기
    var clothSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            selectedClothInfoSection
            
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
        if let detail = viewModel.codiDetail {
            CodiInfoSection(name: detail.name, memo: detail.memo)
        }
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
    
    /// 현재 선택된 개별 의류 상세 텍스트
    @ViewBuilder
    var selectedClothInfoSection: some View {
        if let selectedIndex = viewModel.selectedIndex,
           selectedIndex < viewModel.clothItems.count {
            SelectedClothInfo(entity: viewModel.clothItems[selectedIndex])
                .padding(.horizontal, 20)
        }
    }
    
    /// 셀렉터 내 개별 의류 아이템 셀
    func clothItemCell(at index: Int, item: CodiItem) -> some View {
        SelectableClothItem(
            entity: CodiItemEntity(
                id: item.id,
                imageName: item.imageName,
                x: 0, y: 0, width: 68, height: 68
            ),
            isSelected: Binding(
                get: { viewModel.selectedIndex == index },
                set: { isSelected in
                    viewModel.selectCloth(at: isSelected ? index : -1)
                }
            )
        )
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

/// 선택된 의류 브랜드/이름 정보
private struct SelectedClothInfo: View {
    let entity: CodiItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.brand).font(.caption).foregroundColor(.gray)
            Text(entity.name).font(.body)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
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
