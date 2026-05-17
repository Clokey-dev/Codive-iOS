//
//  EraserEditorView.swift
//  Codive
//
//  Created by 황상환 on 2/22/26.
//

import SwiftUI

// MARK: - DrawingLine
struct DrawingLine: Identifiable {
    let id = UUID()
    var path: Path
    var lineWidth: CGFloat
}

// MARK: - EraserEditorView
struct EraserEditorView: View {

    // MARK: - Properties
    let originalImage: UIImage
    let photoIndex: Int
    let navigationRouter: NavigationRouter
    @ObservedObject var clothAddViewModel: ClothAddViewModel
    let onSaveImage: (UIImage) -> Void

    @State private var lines: [DrawingLine] = []
    @State private var redoLines: [DrawingLine] = []
    @State private var currentPath = Path()
    @State private var brushSize: CGFloat = 30.0
    @State private var canvasSize: CGSize = .zero
    @State private var showBackAlert = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: "직접 수정하기",
                onBack: {
                    showBackAlert = true
                },
                rightButton: .text(
                    title: "완료",
                    isEnabled: true
                ) {
                    let result = saveImage()
                    onSaveImage(result)
                    navigationRouter.navigate(to: .eraserPreview(photoIndex: photoIndex))
                }
            )

            Spacer()

            // 작업 영역
            ZStack {
                CheckerboardBackground()

                GeometryReader { geo in
                    Canvas { context, size in
                        let image = Image(uiImage: originalImage)
                        context.draw(image, in: CGRect(origin: .zero, size: size))

                        context.blendMode = .destinationOut

                        for line in lines {
                            context.stroke(
                                line.path,
                                with: .color(.black),
                                style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round)
                            )
                        }

                        context.stroke(
                            currentPath,
                            with: .color(.black),
                            style: StrokeStyle(lineWidth: brushSize, lineCap: .round, lineJoin: .round)
                        )
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if currentPath.isEmpty {
                                    currentPath.move(to: value.location)
                                } else {
                                    currentPath.addLine(to: value.location)
                                }
                            }
                            .onEnded { _ in
                                let newLine = DrawingLine(path: currentPath, lineWidth: brushSize)
                                lines.append(newLine)
                                currentPath = Path()
                                redoLines.removeAll()
                            }
                    )
                    .onAppear {
                        canvasSize = geo.size
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)

            Spacer()

            // 하단 툴바
            VStack(spacing: 16) {
                // 붓 크기 미리보기
                Circle()
                    .fill(Color.Codive.grayscale4.opacity(0.5))
                    .frame(width: brushSize, height: brushSize)
                    .frame(height: 50)
                    .animation(.easeOut(duration: 0.1), value: brushSize)

                // 크기 슬라이더
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.Codive.grayscale3)
                        .frame(width: 8, height: 8)
                    Slider(value: $brushSize, in: 10...100)
                        .tint(Color.Codive.grayscale3)
                    Circle()
                        .fill(Color.Codive.grayscale3)
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 20)

                // 되돌리기 / 다시하기
                HStack(spacing: 32) {
                    Button {
                        if let last = lines.popLast() {
                            redoLines.append(last)
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(lines.isEmpty ? Color.Codive.grayscale5 : Color.Codive.grayscale2)
                    }
                    .disabled(lines.isEmpty)

                    Button {
                        if let last = redoLines.popLast() {
                            lines.append(last)
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(redoLines.isEmpty ? Color.Codive.grayscale5 : Color.Codive.grayscale2)
                    }
                    .disabled(redoLines.isEmpty)
                }
            }
            .padding(.bottom, 30)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.white)
        .alert("수정을 그만할까요?", isPresented: $showBackAlert) {
            Button("취소", role: .cancel) {}
            Button("나가기", role: .destructive) {
                navigationRouter.navigateBack()
            }
        } message: {
            Text("지금 나가면 수정 내용이 사라져요.")
        }
    }

    // MARK: - Save Image
    @MainActor
    func saveImage() -> UIImage {
        let currentCanvasSize = (canvasSize == .zero) ? originalImage.size : canvasSize
        let scaleFactor = originalImage.size.width / currentCanvasSize.width

        let renderer = ImageRenderer(content:
            Canvas { context, size in
                let image = Image(uiImage: originalImage)
                context.draw(image, in: CGRect(origin: .zero, size: size))

                context.blendMode = .destinationOut
                context.scaleBy(x: scaleFactor, y: scaleFactor)

                for line in lines {
                    context.stroke(
                        line.path,
                        with: .color(.black),
                        style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round)
                    )
                }
            }
            .frame(width: originalImage.size.width, height: originalImage.size.height)
        )

        renderer.scale = 1.0
        renderer.isOpaque = false
        return renderer.uiImage ?? originalImage
    }
}

// MARK: - CheckerboardBackground
struct CheckerboardBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let size: CGFloat = 20.0
            let rows = Int(geometry.size.height / size) + 1
            let cols = Int(geometry.size.width / size) + 1

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { col in
                            Rectangle()
                                .fill((row + col) % 2 == 0 ? Color.white : Color.gray.opacity(0.2))
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
    }
}
