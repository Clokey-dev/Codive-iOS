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
    @State private var agreements: [Int64: Bool] = [:]
    
    // 서버에서 받아온 약관 목록
    @State private var termsList: [TermItem] = []

    // 로딩 상태
    @State private var isLoading = false
    @State private var errorMessage: String?

    // 전체 동의 여부
    private var isAllAgreed: Bool {
        guard !termsList.isEmpty else { return false }
        return agreements.values.allSatisfy { $0 } && agreements.count == termsList.count
    }

    // 필수 항목 동의 여부
    private var canProceed: Bool {
        let requiredTerms = termsList.filter { !$0.isOptional }
        return requiredTerms.allSatisfy { agreements[$0.termId] == true }
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
            
            if isLoading && termsList.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                // 약관 리스트 섹션
                VStack(spacing: 0) {
                    // 전체 동의
                    AgreementRow(
                        title: "전체 동의",
                        isAgreed: Binding(
                            get: { isAllAgreed },
                            set: { newValue in
                                for term in termsList {
                                    agreements[term.termId] = newValue
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
                    ForEach(termsList, id: \.termId) { term in
                        AgreementRow(
                            title: term.title,
                            isAgreed: binding(for: term.termId),
                            isRequired: !term.isOptional
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }

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
                text: isLoading && !termsList.isEmpty ? "처리 중..." : "가입 완료",
                widthType: .fixed,
                isEnabled: canProceed && (!isLoading || termsList.isEmpty)
            ) {
                submitAgreements()
            }
            .frame(height: 56)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .navigationBarHidden(true)
        .task {
            await loadTerms()
        }
    }

    // MARK: - Helper Methods
    
    private func loadTerms() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedTerms = try await termsAPIService.fetchTerms()
            termsList = fetchedTerms
            
            // agreements 초기화
            for term in fetchedTerms {
                if agreements[term.termId] == nil {
                    agreements[term.termId] = false
                }
            }
        } catch {
            errorMessage = "약관 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

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
                // 동의한 항목만 필터링하거나 전체 전송 (API 명세에 따름)
                // 여기서는 체크된 항목들의 리스트를 전송
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
