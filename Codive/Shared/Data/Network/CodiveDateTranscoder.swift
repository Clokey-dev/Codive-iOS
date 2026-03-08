//
//  CodiveDateTranscoder.swift
//  Codive
//

import Foundation
import OpenAPIRuntime

/// 서버의 다양한 날짜 포맷(나노초 포함)을 처리하는 커스텀 DateTranscoder
struct CodiveDateTranscoder: DateTranscoder {

    private let lock = NSLock()

    func encode(_ date: Date) throws -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    func decode(_ dateString: String) throws -> Date {
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
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) { return date }
        }

        throw DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "날짜 파싱 실패: \(dateString)")
        )
    }
}
