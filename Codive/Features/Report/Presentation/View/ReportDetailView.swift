//
//  ReportDetailView.swift
//  Codive
//
//  Created by 한태빈 on 10/16/25.
//
// 상세 사유 나중에 넣어주기

import SwiftUI

struct ReportDetailView: View {
    @ObservedObject var vm: ReportViewModel
    var onSubmit: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CustomNavigationBar(title: vm.navTitle) {
                    // 뒤로가기 액션
                }

                // MARK: 선택된 신고 사유
                VStack(alignment: .leading, spacing: 12) {
                    Text("선택된 신고 사유")
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
                        Text("문제가 된 부분을 구체적으로 작성해 주세요.")
                            .font(.codive_body1_bold)
                            .foregroundStyle(Color.Codive.grayscale1)

                        ZStack(alignment: .topLeading) {
                            // Placeholder – 내용이 비어 있을 때만 보이도록
                            if vm.draftDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("예시: 욕설을 사용한 특정 문장, 협박성 메시지 등")
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

                    // MARK: 안내 문구
                    VStack(alignment: .leading, spacing: 16) {
                        NoticeRow(text: "신고 접수 후 패널티 조치까지 영업일 기준 최소 3영업일에서 최대 5영업일 소요될 수 있습니다.")
                        NoticeRow(text: "신고가 접수되면 해당 기록이 일시적으로 제한될 수 있으며, 상단의 사유와 함께 검토됩니다.")
                        NoticeRow(text: "신고 내용에 대한 사실 확인이 필요할 경우, CloKey 고객센터를 통해 신고자에게 추가적인 자료 제출을 요청할 수 있습니다.")
                        NoticeRow(text: "신고가 누적 3회 이상일 경우 계정이 정지되며, 허위 신고가 3회 적발될 경우에도 동일하게 제재가 집행됩니다.")
                    }
                    .padding(.top, 12)

                    CustomButton(text: "신고하기", widthType: .fixed) {
                        onSubmit?()
                    }
                    .padding(.top, 125)
                    .disabled(!vm.isNextEnabled || vm.isSubmitting)
                }
                .padding(.horizontal, 20) 
            }
        }
    }

    // 부가: 경고/안내 한 줄
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
