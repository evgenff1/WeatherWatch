//
//  String+Localization.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 12.09.2024.
//

import Foundation

extension String {
    
    // MARK: - Localization
    
    /// Локализированное значение строки.
    /// - Returns: Локализированная строка на основе текущего языка системы.
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

