//
//  ReportDetailView.swift
//  Codive
//
//  Created by 한태빈 on 10/16/25.
//

import SwiftUI

struct ReportDetailView: View {
    @ObservedObject var vm: ReportViewModel
    @ObservedObject var navigationRouter: NavigationRouter
    var onSubmit: (() -> Void)?
    var onDuplicateDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: vm.navTitle,
                onBack: onBackTapped
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 선택된 신고 사유
                    VStack(alignment: .leading, spacing: 12) {
                        Text(TextLiteral.Report.selectedReasonSection)
                            .font(.codive_title2)
                            .foregroundStyle(Color.Codive.grayscale1)

                        Text("· \(vm.selectedReason?.title ?? "")")
                            .font(.codive_body2_medium)
                            .foregroundStyle(Color.Codive.grayscale1)
                            .padding(.vertical, 12)
                            .padding(.leading, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("main6"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.bottom, 12)

                        // 상세 이유 작성
                        VStack(alignment: .leading, spacing: 12) {
                            Text(TextLiteral.Report.detailSection)
                                .font(.codive_body1_bold)
                                .foregroundStyle(Color.Codive.grayscale1)

                            ZStack(alignment: .topLeading) {
                                if vm.draftDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Text(TextLiteral.Report.detailPlaceholder)
                                        .font(.codive_body2_regular)
                                        .foregroundStyle(Color.Codive.grayscale3)
                                        .padding(.leading, 16)
                                        .padding(.top, 16)
                                }

                                TextEditor(
                                    text: Binding(
                                        get: { vm.draftDetail },
                                        set: { vm.updateDetail($0) }
                                    )
                                )
                                .font(.codive_body2_regular)
                                .foregroundStyle(Color.Codive.grayscale1)
                                .padding(.leading, 16)
                                .padding(.top, 16)
                                .frame(minHeight: 120, alignment: .topLeading)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.Codive.grayscale1, lineWidth: 1)
                                )
                            }
                        }

                        // 안내 문구
                        VStack(alignment: .leading, spacing: 16) {
                            NoticeRow(text: "신고 접수 후 패널티 조치까지 영업일 기준 최소 3영업일에서 최대 5영업일 소요될 수 있습니다.")
                            NoticeRow(text: "신고가 접수되면 해당 기록이 일시적으로 제한될 수 있으며, 상단의 사유와 함께 검토됩니다.")
                            NoticeRow(text: "신고 내용에 대한 사실 확인이 필요할 경우, CloKey 고객센터를 통해 신고자에게 추가적인 자료 제출을 요청할 수 있습니다.")
                            NoticeRow(text: "신고가 누적 3회 이상일 경우 계정이 정지되며, 허위 신고가 3회 적발될 경우에도 동일하게 제재가 집행됩니다.")
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .font(.codive_body3_regular)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 20)
                    }

                    CustomButton(text: TextLiteral.Report.submit, widthType: .fixed) {
                        onSubmit?()
                    }
                    .disabled(!vm.isNextEnabled || vm.isSubmitting)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("신고 안내", isPresented: $vm.showDuplicateAlert) {
            Button("확인") {
                onDuplicateDismiss?()
            }
        } message: {
            Text(vm.duplicateAlertMessage)
        }
    }

    // MARK: - Navigation
    private func onBackTapped() {
        navigationRouter.navigateBack()
    }

    private struct NoticeRow: View {
        let text: String
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.Codive.grayscale4)

                Text(text)
                    .font(.codive_body2_regular)
                    .foregroundStyle(Color.Codive.grayscale4)
            }
        }
    }
}
