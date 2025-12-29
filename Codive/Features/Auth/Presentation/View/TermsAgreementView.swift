//
//  TermsAgreementView.swift
//  Codive
//
//  Created by 황상환 on 9/20/25.
//

import SwiftUI

struct TermsAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 약관 상태 관리
    @State private var isServiceAgreed = false
    @State private var isPrivacyAgreed = false
    @State private var isLocationAgreed = false
    @State private var isMarketingAgreed = false
    
    // 전체 동의 계산 프로퍼티
    private var isAllAgreed: Bool {
        get {
            isServiceAgreed && isPrivacyAgreed && isLocationAgreed && isMarketingAgreed
        }
        set {
            isServiceAgreed = newValue
            isPrivacyAgreed = newValue
            isLocationAgreed = newValue
            isMarketingAgreed = newValue
        }
    }
    
    // 필수 항목 동의 여부 확인
    private var canProceed: Bool {
        isServiceAgreed && isPrivacyAgreed && isLocationAgreed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 상단 뒤로가기 버튼
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.codive_title1)
                    .foregroundColor(.Codive.main1)
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
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
                            // isAllAgreed = newValue 대신 개별 State를 직접 변경합니다.
                            isServiceAgreed = newValue
                            isPrivacyAgreed = newValue
                            isLocationAgreed = newValue
                            isMarketingAgreed = newValue
                        }
                    ),
                    isBold: true,
                    showChevron: false
                )
                
                Divider()
                    .background(Color.Codive.grayscale2)
                    .padding(.vertical, 10)
                
                // 개별 항목들
                AgreementRow(title: "(필수) 서비스 이용약관", isAgreed: $isServiceAgreed, isRequired: true)
                AgreementRow(title: "(필수) 개인정보 수집/이용 동의", isAgreed: $isPrivacyAgreed, isRequired: true)
                AgreementRow(title: "(필수) 위치 기반 서비스 이용약관 동의", isAgreed: $isLocationAgreed, isRequired: true)
                AgreementRow(title: "(선택) 마케팅 정보수신 동의", isAgreed: $isMarketingAgreed, isRequired: false)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
            
            // 가입 완료 버튼
            CustomButton(text: "가입 완료", widthType: .fixed, isEnabled: canProceed) {
                // 회원가입 완료 로직
            }
            .frame(height: 56)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .navigationBarHidden(true)
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
                Text(title.replacingOccurrences(of: "(필수) ", with: "").replacingOccurrences(of: "(선택) ", with: ""))
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
    TermsAgreementView()
}
