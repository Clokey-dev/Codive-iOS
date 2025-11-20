//
//  SortOption.swift
//  Codive
//
//  Created by 한금준 on 11/19/25.
//

import SwiftUI

struct SortOption: View {
    let options: [String]
    @Binding var selectedOption: String
    
    @State private var isDropdownExpanded: Bool = false

    init(mainText: String, options: [String], selectedOption: Binding<String>) {
        self.options = options
        self._selectedOption = selectedOption
    }
 
    var body: some View {
        toggleButton
            .overlay(alignment: .topTrailing) {
                if isDropdownExpanded {
                    menuOptionsView
                        .offset(y: 30)
                        .transition(
                            .opacity
                                .combined(with: .scale(scale: 0.9, anchor: .topTrailing))
                        )
                }
            }
    }

    private var toggleButton: some View {
        Button(
            action: {
                withAnimation(.spring()) {
                    isDropdownExpanded.toggle()
                }
            },
            label: {
                HStack(spacing: 7) {
                    Text(selectedOption)
                        .font(Font.codive_body2_medium)
                        .foregroundColor(Color.Codive.grayscale3)
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 8)
                        .rotationEffect(.degrees(isDropdownExpanded ? 180 : 0))
                        .foregroundColor(Color.Codive.grayscale3)
                }
            }
        )
    }
 
    private var menuOptionsView: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                optionButton(option)
                
                if option != options.last {
                    Divider()
                        .padding(.horizontal, -15)
                }
            }
        }
        .background(Color.white)
        .frame(width: 80)
        .cornerRadius(10)
        .shadow(radius: 8, x: 0, y: 2)
        .zIndex(100)
    }

    private func optionButton(_ option: String) -> some View {
        Button(
            action: {
                handleOptionSelection(option)
            },
            label: {
                Text(option)
                    .font(Font.codive_body2_medium)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(option == selectedOption ? Color.Codive.grayscale1 : Color.Codive.grayscale3)
            }
        )
        .buttonStyle(.plain)
    }

    private func handleOptionSelection(_ option: String) {
        selectedOption = option
        
        withAnimation(.easeOut(duration: 0.2)) {
            isDropdownExpanded = false
        }
    }
}

// MARK: - Preview
struct SortOption_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var currentSort: String = "인기순"
        let sortOptions = ["인기순", "최신순"]
        
        var body: some View {
            VStack(alignment: .trailing) {
                SortOption(
                    mainText: "전체",
                    options: sortOptions,
                    selectedOption: $currentSort
                )
                
                Spacer()
                
                Text("현재 정렬: **\(currentSort)**")
                    .padding()
            }
            .padding()
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
