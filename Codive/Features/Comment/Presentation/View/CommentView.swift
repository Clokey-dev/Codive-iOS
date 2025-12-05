// Codive/Features/Comment/Presentation/View/CommentView.swift

import SwiftUI

struct CommentView: View {
    @StateObject var viewModel: CommentViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("댓글")
                    .font(.headline)
                Spacer()
                Button(action: {
                    // TODO: 닫기 액션
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            // MARK: - Comment List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    ForEach(viewModel.comments) { comment in
                        CommentRow(comment: comment)
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .onAppear {
                viewModel.fetchFirstPage()
            }
            
            Divider()
            
            // MARK: - Comment Input
            HStack {
                TextField("댓글을 입력하세요...", text: $viewModel.currentCommentText)
                    .textFieldStyle(.roundedBorder)
                Button("등록") {
                    viewModel.postComment()
                }
                .disabled(viewModel.currentCommentText.isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16, corners: [.topLeft, .topRight]) // 바텀시트 모양
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - CommentRow (임시)
struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person.circle.fill") // 프로필 이미지 대체
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(comment.author.nickname ?? "익명")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(comment.content)
                    .font(.callout)
            }
            Spacer()
        }
    }
}

// MARK: - Preview
struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Repository를 사용하여 ViewModel 생성
        let mockRepository = MockCommentRepository()
        let viewModel = CommentViewModel(feedId: 1, commentRepository: mockRepository)
        
        // 미리보기에서 데이터 로드를 트리거하기 위해 Task 사용
        // 실제 앱에서는 onAppear에서 호출됩니다.
        _ = Task {
            await viewModel.fetchFirstPage()
        }
        
        return CommentView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
            .frame(height: 500) // 바텀시트 높이 시뮬레이션
    }
}

// CornerRadius extension (optional, for aesthetics)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
