//
//  AddBottomSheet.swift
//  Codive
//
//  Created by 한금준 on 12/26/25.
//

import SwiftUI

// MARK: - Reusable BottomSheet

struct BottomSheet<Content: View>: View {
    @Binding var isPresented: Bool

    private let title: String?
    private let showsGrabber: Bool
    private let onDismiss: (() -> Void)?
    private let sheetHeight: CGFloat

    @State private var translationY: CGFloat = 0

    // MARK: - Initializer
    
    /// 바텀시트를 구성하는 데 필요한 설정 값들을 주입하는 초기화 함수
    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        showsGrabber: Bool = true,
        sheetHeight: CGFloat = 500,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.showsGrabber = showsGrabber
        self.sheetHeight = sheetHeight
        self.onDismiss = onDismiss
        self.content = content()
    }

    // MARK: - Body
    
    /// 딤 처리된 배경 위에 바텀시트를 하단 정렬로 배치하는 레이아웃
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                // Dimmed background
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }

                sheetBody
                    .transition(.move(edge: .bottom))
                    .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isPresented)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private let content: Content

    // MARK: - Sheet Layout
    
    /// 상단 그랩바, 타이틀, 컨텐츠를 포함한 바텀시트 내부 레이아웃
    private var sheetBody: some View {
        VStack(spacing: 0) {
            if showsGrabber {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 69, height: 5)
                    .padding(.top, 12)
            }

            if let title = title {
                Text(title)
                    .font(.codive_title2)
                    .foregroundStyle(Color.Codive.grayscale1)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
            }

            VStack(spacing: 0) {
                content
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)

            Color.clear.frame(height: 34)
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: sheetHeight)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .offset(y: translationY)
        .gesture(dragGesture)
    }

    // MARK: - Gesture
    
    /// 바텀시트를 아래로 드래그하여 닫을 수 있도록 처리하는 드래그 제스처
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    translationY = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > 120 {
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        translationY = 0
                    }
                }
            }
    }

    // MARK: - Private Helpers
    
    /// 바텀시트를 닫고, onDismiss 콜백을 실행하는 헬퍼 함수
    private func dismiss() {
        withAnimation { isPresented = false }
        onDismiss?()
        translationY = 0
    }
}

// MARK: - LookBook Card View

/// 썸네일, 제목, 코디 개수를 보여주는 룩북 카드 컴포넌트
struct LookBookSheetCardView<Thumbnail: View>: View {
    let entity: LookBookBottomSheetEntity
    /// 외부에서 주입받는 썸네일 뷰 (예: AsyncImage, Kingfisher, 로컬 Image 등)
    let thumbnail: Thumbnail?
    /// 카드 전체를 탭했을 때 실행할 액션
    let onTap: (() -> Void)?

    // MARK: - Body
    
    /// 카드 전체를 버튼으로 감싸 탭 시 onTap 클로저를 호출하는 레이아웃
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11.18, style: .continuous)
                        .fill(Color.Codive.grayscale5)
                        .frame(width: 76, height: 76)

                    if let thumbnail {
                        thumbnail
                            .frame(width: 76, height: 76)
                            .clipShape(RoundedRectangle(cornerRadius: 11.18))
                    } else {
                        defaultImage
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(entity.title)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale1)

                    Text("\(entity.count)")
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color.Codive.grayscale4)
                }

                Spacer()
            }
            .padding(.leading, 8)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(Color.Codive.grayscale5, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Placeholder
    
    /// 썸네일이 없거나 로딩 실패 시 표시할 기본 이미지
    private var defaultImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .padding(12)
            .foregroundStyle(Color(.systemGray3))
    }
}

// MARK: - AddBottomSheet (룩북 선택 바텀시트)

/// 룩북 리스트를 그리드 형태로 보여주고, 선택 시 콜백을 전달하는 바텀시트
struct AddBottomSheet<Thumbnail: View>: View {
    @Binding var isPresented: Bool
    /// 룩북 바텀시트에 표시할 엔티티 리스트
    let entities: [LookBookBottomSheetEntity]
    /// 각 엔티티에 대한 썸네일 뷰를 외부에서 주입 (예: AsyncImage, KFImage 등)
    let thumbnailProvider: (LookBookBottomSheetEntity) -> Thumbnail?
    /// 엔티티 선택 시 콜백 (lookbookId, codiId 등을 상위에서 활용)
    let onTapEntity: (LookBookBottomSheetEntity) -> Void

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Body
    
    /// 공통 BottomSheet 위에 룩북 카드들을 2열 그리드로 배치하는 레이아웃
    var body: some View {
        BottomSheet(
            isPresented: $isPresented,
            title: "룩북에 추가",
            sheetHeight: UIScreen.main.bounds.height * 0.75
        ) {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(entities) { entity in
                        LookBookSheetCardView(
                            entity: entity,
                            thumbnail: thumbnailProvider(entity),
                            onTap: { onTapEntity(entity) }
                        )
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Preview

/// 룩북 선택 바텀시트의 레이아웃과 스타일을 확인하기 위한 프리뷰
struct AddBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntities: [LookBookBottomSheetEntity] = [
            .init(lookbookId: 1, codiId: 101, imageUrl: "https://example.com/1.png", title: "운동룩", count: 6),
            .init(lookbookId: 2, codiId: 102, imageUrl: "https://example.com/2.png", title: "출근룩", count: 12),
            .init(lookbookId: 3, codiId: 103, imageUrl: "https://example.com/3.png", title: "데이트룩", count: 16),
            .init(lookbookId: 4, codiId: 104, imageUrl: "https://example.com/4.png", title: "독서실룩", count: 8),
            .init(lookbookId: 5, codiId: 105, imageUrl: "https://example.com/5.png", title: "스페인여행", count: 20)
        ]

        ZStack {
            Color(.systemGray5)
                .ignoresSafeArea()

            AddBottomSheet(
                isPresented: .constant(true),
                entities: sampleEntities,
                thumbnailProvider: { _ in
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                },
                onTapEntity: { _ in }
            )
        }
    }
}
