//
//  ReportView.swift
//  Codive
//
//  Created by 한태빈 on 10/14/25.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var vm: ReportViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CustomNavigationBar(title: "기록 신고하기") {
                    print("뒤로가기")
                }
                reportingUser
                reportingContent
                Divider()
                reportingReasons
                CustomButton(text: "다음", widthType: .fixed) {
                    print("이 코디 결정 tapped!")
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
            }
        }
    }
    private var reportingUser: some View {
        VStack(alignment: .leading) {
            Text("작성자")
                .font(.codive_title2)
                .foregroundStyle(Color("Grayscale1"))
                .padding(.bottom, 12)
                .padding(.leading, 20)
            
            Group {
                HStack {
                    Image("CustomProfile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text("닉네임")
                            .font(.codive_body1_medium)
                            .foregroundStyle(Color("Grayscale1"))

                        Text("아이디")
                            .font(.codive_body3_medium)
                            .foregroundStyle(Color("Grayscale3"))
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
    private var reportingContent: some View {
        VStack(alignment: .leading) {
            Text(vm.contentSectionTitle) // "기록 내용" / "댓글 내용"
                .font(.codive_title2)
                .foregroundStyle(Color("Grayscale1"))
                .padding(.bottom, 12) // 원래 8 → 12로 유지

            Text(vm.contentText)
                .font(.codive_body3_regular)
                .foregroundStyle(Color("Grayscale2"))
                .lineLimit(nil)
        }
        .padding(.horizontal, 20)
    }
    
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
                            .onTapGesture { vm.selectedReason = reason }

                        Text(reason.title)
                            .font(.codive_body2_regular)
                            .foregroundStyle(Color("Grayscale1"))
                            .onTapGesture { vm.selectedReason = reason }
                    }

                    // 선택된 항목의 보조 설명(이거 근데 보조 설명이 하나밖에 없음
                    if let sub = reason.subDescription, vm.selectedReason == reason {
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
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    // 게시글 신고 화면 프리뷰
    ReportView(
        vm: ReportViewModel(
            target: .post,                         // .comment 로 바꾸면 댓글용
            authorName: "닉네임",
            authorId: "아이디",
            contentText: "본문내용본문내용본문내용본문내용본문내용본문내용본문내용본문내용본문내용본문내용본문내용본문내용"
        )
    )
}
