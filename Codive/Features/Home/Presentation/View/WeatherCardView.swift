//
//  WeatherCardView.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

struct WeatherCardView: View {
    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color.Codive.main0)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("30°")
                        .font(Font.codive_title1)
                        .foregroundColor(Color.Codive.main0)
                    
                    // 온도 슬라이더
                    VStack(spacing: 4) {
                        ZStack(alignment: .center) {
                            Capsule()
                                .fill(Color.Codive.grayscale5)
                                .frame(height: 4)

                            Capsule()
                                .fill(Color.Codive.main0)
                                .frame(width: 95, height: 4)
                        }
                        .frame(width: 110)
                        .padding(.top, 2)

                        HStack {
                            Text("24°")
                            Spacer()
                            Text("32°")
                        }
                        .font(Font.codive_body4_regular)
                        .foregroundColor(Color.Codive.main0)
                        .frame(width: 110)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 10))
                    Text("Weather")
                        .font(.system(size: 10))
                }
                .foregroundColor(.black)
                
                HStack(spacing: 4) {
                    Text("서울특별시")
                        .font(Font.codive_body1_medium)
                    Image(systemName: "dot.scope")
                        .foregroundColor(Color.Codive.main1)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.Codive.grayscale7)
        .cornerRadius(12)
    }
}

#Preview {
    WeatherCardView()
        .padding(.horizontal, 20)
}
