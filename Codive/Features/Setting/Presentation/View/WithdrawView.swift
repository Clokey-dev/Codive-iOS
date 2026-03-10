//
//  WithdrawView.swift
//  Codive
//
//  Created by 한태빈 on 10/17/25.
//

import SwiftUI

struct WithdrawView: View {
    @ObservedObject private var vm: WithdrawViewModel

    init(vm: WithdrawViewModel) {
        self._vm = ObservedObject(wrappedValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: TextLiteral.Setting.withdrawTitle) {
                vm.navigateBack()
            }

            VStack {
                HStack {
                    Image("orangeWarning")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.leading, 20)

                    Text(TextLiteral.Setting.withdrawNotice)
                        .font(.codive_title2)
                        .foregroundStyle(Color.Codive.grayscale1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 32)

                Image("withdraw1")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 12)
                    .padding(.horizontal, 20)
                Image("withdraw2")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 20)

                Spacer()

                CustomButton(
                    text: vm.isLoading ? TextLiteral.Setting.withdrawButtonLoading : TextLiteral.Setting.withdrawButton,
                    widthType: .fixed,
                    isEnabled: !vm.isLoading
                ) {
                    vm.onWithdrawTapped()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .enableSwipeBack {
            vm.navigateBack()
        }
        .alert(TextLiteral.Setting.withdrawConfirmTitle, isPresented: $vm.showConfirmAlert) {
            Button("취소", role: .cancel) { }
            Button("탈퇴하기", role: .destructive) {
                Task {
                    vm.confirmWithdraw()
                }
            }
        } message: {
            Text(TextLiteral.Setting.withdrawConfirmMessage)
        }
        .alert("탈퇴 완료", isPresented: $vm.showCompleteAlert) {
            Button("확인") {
                vm.confirmWithdrawComplete()
            }
        } message: {
            Text("탈퇴가 완료되었습니다.")
        }
    }
}

#Preview {
    EmptyView()
}
