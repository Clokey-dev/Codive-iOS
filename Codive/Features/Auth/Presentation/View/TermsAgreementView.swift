//
//  TermsAgreementView.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

struct TermsAgreementView: View {
    @Environment(\.dismiss) private var dismiss

    // 완료 콜백
    let onComplete: () -> Void

    // API Service
    private let termsAPIService: TermsAPIServiceProtocol

    // 약관 상태 관리 (termId 매핑)
    @State private var agreements: [Int64: Bool] = [
        1: false,  // 서비스 이용약관 (필수)
        2: false,  // 개인정보 처리방침 (필수)
        3: false,  // 위치기반 서비스 이용약관 (필수)
        4: false,  // 마케팅 정보 수신 동의 (선택)
        5: false   // 푸시 알림 수신 동의 (선택)
    ]

    // 로딩 상태
    @State private var isLoading = false
    @State private var errorMessage: String?

    // 전체 동의 여부
    private var isAllAgreed: Bool {
        agreements.values.allSatisfy { $0 }
    }

    // 필수 항목 동의 여부 (termId 1, 2, 3)
    private var canProceed: Bool {
        (agreements[1] ?? false) && (agreements[2] ?? false) && (agreements[3] ?? false)
    }

    init(
        onComplete: @escaping () -> Void,
        termsAPIService: TermsAPIServiceProtocol = TermsAPIService()
    ) {
        self.onComplete = onComplete
        self.termsAPIService = termsAPIService
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 타이틀
            Text("약관에 동의하시면\n회원가입이 완료됩니다.")
                .font(.codive_title1)
                .lineSpacing(6)
                .padding(.top, 30)
                .padding(.horizontal, 20)

            Spacer()

            // 약관 리스트 섹션
            VStack(spacing: 0) {
                // 전체 동의
                AgreementRow(
                    title: "전체 동의",
                    isAgreed: Binding(
                        get: { isAllAgreed },
                        set: { newValue in
                            for key in agreements.keys {
                                agreements[key] = newValue
                            }
                        }
                    ),
                    isBold: true,
                    showChevron: false
                )

                Divider()
                    .background(Color.Codive.grayscale2)
                    .padding(.vertical, 10)

                // 개별 항목들
                AgreementRow(
                    title: "서비스 이용약관",
                    isAgreed: binding(for: 1),
                    isRequired: true
                )
                AgreementRow(
                    title: "개인정보 수집/이용 동의",
                    isAgreed: binding(for: 2),
                    isRequired: true
                )
                AgreementRow(
                    title: "위치 기반 서비스 이용약관 동의",
                    isAgreed: binding(for: 3),
                    isRequired: true
                )
                AgreementRow(
                    title: "마케팅 정보수신 동의",
                    isAgreed: binding(for: 4),
                    isRequired: false
                )
                AgreementRow(
                    title: "푸시 알림 수신 동의",
                    isAgreed: binding(for: 5),
                    isRequired: false
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)

            // 에러 메시지
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.codive_body3_regular)
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }

            // 가입 완료 버튼
            CustomButton(
                text: isLoading ? "처리 중..." : "가입 완료",
                widthType: .fixed,
                isEnabled: canProceed && !isLoading
            ) {
                submitAgreements()
            }
            .frame(height: 56)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Helper Methods

    private func binding(for termId: Int64) -> Binding<Bool> {
        Binding(
            get: { agreements[termId] ?? false },
            set: { agreements[termId] = $0 }
        )
    }

    private func submitAgreements() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // 동의 정보 생성
                let termAgreements = agreements.map { termId, agreed in
                    TermAgreement(termId: termId, agreed: agreed)
                }

                // POST /terms 호출
                try await termsAPIService.agreeTerms(agreements: termAgreements)

                // 메인으로 이동
                await MainActor.run {
                    isLoading = false
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "약관 동의에 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
}

// 개별 약관 로우 컴포넌트
struct AgreementRow: View {
    let title: String
    @Binding var isAgreed: Bool
    var isBold: Bool = false
    var isRequired: Bool? = nil
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            // 체크박스
            Button(action: { isAgreed.toggle() }) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.codive_title1)
                    .foregroundColor(isAgreed ? .Codive.point1 : .Codive.point4)
            }

            // 제목 (필수/선택 강조 포함)
            HStack(spacing: 4) {
                if let isRequired = isRequired {
                    Text(isRequired ? "(필수)" : "(선택)")
                        .foregroundColor(isRequired ? .Codive.point1 : .Codive.grayscale4)
                }
                Text(title)
            }
            .font(isBold ? .codive_body1_bold : .codive_body1_regular)
            .foregroundColor(isBold ? .Codive.grayscale1 : .Codive.grayscale4)

            Spacer()

            // 상세 보기 버튼
            if showChevron {
                Button(action: { /* 상세 페이지 이동 */ }) {
                    Image(systemName: "chevron.right")
                        .font(.codive_body2_regular)
                        .foregroundColor(.Codive.grayscale4)
                }
            }
        }
        .frame(height: 44)
    }
}

#Preview {
    TermsAgreementView(onComplete: {})
}
