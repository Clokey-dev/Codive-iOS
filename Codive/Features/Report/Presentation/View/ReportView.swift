//
//  ReportView.swift
//  Codive
//
//  Created by 한태빈 on 10/14/25.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var vm: ReportViewModel
    @ObservedObject var navigationRouter: NavigationRouter
    var onSubmit: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: vm.navTitle,
                onBack: onBackTapped
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    reportingUser
                    reportingContent
                    Divider()
                    reportingReasons
                }
            }
            .safeAreaInset(edge: .bottom) {
                CustomButton(text: TextLiteral.Report.next, widthType: .fixed) {
                    onSubmit?()
                }
                .disabled(!vm.isNextEnabled || vm.isSubmitting)
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .task { await vm.loadContext() }
    }

    // MARK: - Navigation
    private func onBackTapped() {
        navigationRouter.navigateBack()
    }

    // MARK: 작성자
    private var reportingUser: some View {
        VStack(alignment: .leading) {
            Text(TextLiteral.Report.authorSection)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.bottom, 12)
                .padding(.leading, 20)

            HStack {
                if let avatarURL = vm.context?.author.avatarURL {
                    AsyncImage(url: avatarURL) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image("Profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }

                Text(vm.authorName)
                    .font(.codive_body1_medium)
                    .foregroundStyle(Color.Codive.grayscale1)
            }
            .padding(.leading, 20)
        }
    }

    // MARK: 내용 미리보기
    private var reportingContent: some View {
        VStack(alignment: .leading) {
            Text(vm.contentSectionTitle)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)
                .padding(.bottom, 12)

            Text(vm.contentPreview.isEmpty ? "-" : vm.contentPreview)
                .font(.codive_body3_regular)
                .foregroundStyle(Color.Codive.grayscale2)
                .lineLimit(nil)
        }
        .padding(.horizontal, 20)
    }

    // MARK: 신고 사유
    private var reportingReasons: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(TextLiteral.Report.reasonSection)
                .font(.codive_title2)
                .foregroundStyle(Color.Codive.grayscale1)

            ForEach(vm.reasonList, id: \.self) { reason in
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(vm.selectedReason == reason ? "check_bt" : "Radio_button unchecked")
                            .resizable()
                            .frame(width: 20, height: 20)

                        Text(reason.title)
                            .font(.codive_body2_regular)
                            .foregroundStyle(Color.Codive.grayscale1)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.select(reason: reason)
                    }

                    if let sub = helperLines(for: reason), vm.selectedReason == reason {
                        VStack(alignment: .leading) {
                            ForEach(sub, id: \.self) { line in
                                Text("· \(line)")
                            }
                        }
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .padding(.vertical, 12)
                        .padding(.leading, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.Codive.main6)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    if reason.isEtc, vm.selectedReason == reason {
                        TextEditor(
                            text: Binding(
                                get: { vm.draftDetail },
                                set: { vm.updateDetail($0) }
                            )
                        )
                        .frame(minHeight: 88)
                        .padding(12)
                        .background(Color.Codive.main6)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .font(.codive_body3_regular)
                        .foregroundStyle(Color.Codive.grayscale1)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

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
