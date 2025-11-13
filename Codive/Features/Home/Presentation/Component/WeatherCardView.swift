//
//  WeatherCardView.swift
//  Codive
//
//  Created by 한금준 on 10/12/25.
//

import SwiftUI

struct WeatherCardView: View {
    let weatherData: WeatherData

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Image(systemName: weatherData.symbolName)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.Codive.main0)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(weatherData.currentTemp)°")
                        .font(Font.codive_title1)
                        .foregroundStyle(Color.Codive.main0)

                    if let first = weatherData.dailyForecasts.first {
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
                                Text("\(first.lowTemperature)°")
                                Spacer()
                                Text("\(first.highTemperature)°")
                            }
                            .font(Font.codive_body4_regular)
                            .foregroundStyle(Color.Codive.main0)
                            .frame(width: 110)
                        }
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
                .foregroundStyle(.black)

                HStack(spacing: 4) {
                    Text(weatherData.locationName)
                        .font(Font.codive_body1_medium)
                    Image(systemName: "dot.scope")
                        .foregroundStyle(Color.Codive.main1)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(alignment: .center) {
            Color.Codive.grayscale7
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
