//
//  JSONDecoderFactory.swift
//  Codive
//
//  Created by 황상환 on 1/14/26.
//

import Foundation

// MARK: - JSONDecoderFactory

enum JSONDecoderFactory {

    /// API 응답용 JSONDecoder (다양한 날짜 형식 지원)
    static func makeAPIDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // ISO8601 표준 형식 시도
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) { return date }

            iso8601Formatter.formatOptions = [.withInternetDateTime]
            if let date = iso8601Formatter.date(from: dateString) { return date }

            // 나노초 포함 형식 처리 (서버에서 다양한 자릿수로 응답)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",  // 9자리
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS",   // 8자리
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",    // 7자리
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",     // 6자리
                "yyyy-MM-dd'T'HH:mm:ss.SSS",        // 3자리
                "yyyy-MM-dd'T'HH:mm:ss",            // 소수점 없음
                "yyyy-MM-dd"                         // 날짜만
            ]

            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) { return date }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "날짜 파싱 실패: \(dateString)"
            )
        }
        return decoder
    }
}
