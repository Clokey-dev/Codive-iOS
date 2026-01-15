//
//  AddBottomSheet.swift
//  Codive
//
//  Created by 한금준 on 12/26/25.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    @Binding var isPresented: Bool

    private let title: String?
    private let showsGrabber: Bool
    private let onDismiss: (() -> Void)?
    private let sheetHeight: CGFloat

    @State private var translationY: CGFloat = 0

    // MARK: - Initializer

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

    private func dismiss() {
        withAnimation { isPresented = false }
        onDismiss?()
        translationY = 0
    }
}

// MARK: - LookBook Card View

struct LookBookSheetCardView<Thumbnail: View>: View {
    let entity: LookBookBottomSheetEntity
    let thumbnail: Thumbnail?
    let onTap: (() -> Void)?

    // MARK: - Body

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
    
    private var defaultImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .padding(12)
            .foregroundStyle(Color(.systemGray3))
    }
}

// MARK: - AddBottomSheet (룩북 선택 바텀시트)

struct AddBottomSheet<Thumbnail: View>: View {
    @Binding var isPresented: Bool
    let entities: [LookBookBottomSheetEntity]
    let thumbnailProvider: (LookBookBottomSheetEntity) -> Thumbnail?
    let onTapEntity: (LookBookBottomSheetEntity) -> Void

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Body

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
                            thumbnail: thumbnailProvider(entity)
                        ) {
                            onTapEntity(entity)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}
