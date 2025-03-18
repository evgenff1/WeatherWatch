//
//  Date+Timezone.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 11.09.2024.
//

import Foundation

extension Date {
    
    // MARK: - Timezone Adjustment
    
    /// Преобразование времени с учетом смещения часового пояса.
    /// - Parameter timezoneOffset: Смещение часового пояса в секундах.
    /// - Returns: Дата с учетом смещения.
    func applying(timezoneOffset: Int) -> Date {
        return self.addingTimeInterval(TimeInterval(timezoneOffset) - Constants.DateConstants.timezoneOffset)
    }
}

