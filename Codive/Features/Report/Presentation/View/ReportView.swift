//
//  ReportView.swift
//  Codive
//
//  Created by 한태빈 on 10/14/25.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var vm: ReportViewModel
    var onSubmit: (() -> Void)?   // 필요 시 제출 액션 주입

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CustomNavigationBar(title: vm.navTitle) {
                    // 뒤로가기 액션은 상위에서 주입 권장
                }

                reportingUser
                reportingContent
                Divider()
                reportingReasons

                CustomButton(text: "다음", widthType: .fixed) {
                    onSubmit?()
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .disabled(!vm.isNextEnabled || vm.isSubmitting)
            }
        }
        .task { await vm.loadContext() }
    }

    // MARK: 작성자
    private var reportingUser: some View {
        VStack(alignment: .leading) {
            Text("작성자")
                .font(.codive_title2)
                .foregroundStyle(Color("Grayscale1"))
                .padding(.bottom, 12)
                .padding(.leading, 20)

            Group {
                HStack {
                    // 실제 프로필 이미지는 AsyncImage/Kingfisher로 교체
                    Image("CustomProfile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(vm.authorName)
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color("Grayscale1"))

                        Text(vm.authorHandle)
                            .font(.codive_body3_medium)
                            .foregroundStyle(Color("Grayscale3"))
                    }
                }
            }
            .padding(.leading, 20)
        }
    }

    // MARK: 내용 미리보기
    private var reportingContent: some View {
        VStack(alignment: .leading) {
            Text(vm.contentSectionTitle) // "기록 내용" / "댓글 내용"
                .font(.codive_title2)
                .foregroundStyle(Color("Grayscale1"))
                .padding(.bottom, 12)

            Text(vm.contentPreview)
                .font(.codive_body3_regular)
                .foregroundStyle(Color("Grayscale2"))
                .lineLimit(nil)
        }
        .padding(.horizontal, 20)
    }

    // MARK: 신고 사유
    private var reportingReasons: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("신고 사유")
                .font(.codive_title2)
                .foregroundStyle(Color("Grayscale1"))

            ForEach(vm.reasonList, id: \.self) { reason in
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(vm.selectedReason == reason ? "checked" : "unchecked")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .onTapGesture { vm.select(reason: reason) }

                        Text(reason.title)
                            .font(.codive_body2_regular)
                            .foregroundStyle(Color("Grayscale1"))
                            .onTapGesture { vm.select(reason: reason) }
                    }

                    // 보조 설명(디자인 유지용 간단 매핑)
                    if let sub = helperLines(for: reason), vm.selectedReason == reason {
                        VStack(alignment: .leading) {
                            ForEach(sub, id: \.self) { line in
                                Text("· \(line)")
                            }
                        }
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color("Grayscale1"))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("main6"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // 기타 사유 입력
                    if reason.isEtc, vm.selectedReason == reason {
                        TextEditor(
                            text: Binding(
                                get: { vm.draftDetail },       // VM에 읽기용 computed 준비
                                set: { vm.updateDetail($0) }   // VM 메서드로 반영
                            )
                        )
                        .frame(minHeight: 88)
                        .padding(12)
                        .background(Color("main6"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color("Grayscale1"))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: 디자인 유지용 보조 설명 매핑
    private func helperLines(for reason: ReportReason) -> [String]? {
        switch reason {
        case .post(let r):
            if r == .violence {
                return [
                    "폭력, 학대, 자해, 성매매 등 위험한 행위를 조장",
                    "불법 행위를 암시하거나 조장하는 게시물 (불법 약물, 도박 등)"
                ]
            }
            return nil
        case .comment(let r):
            if r == .discrim {
                return [
                    "성별, 인종, 종교, 성적 지향 등을 이유로 한 차별적 발언",
                    "혐오, 비하, 폭력 조장 또는 위협적인 표현"
                ]
            }
            return nil
        }
    }
}
