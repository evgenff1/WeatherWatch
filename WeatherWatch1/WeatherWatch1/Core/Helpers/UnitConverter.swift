//
//  UnitConverter.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 12.09.2024.
//

import Foundation

/// `UnitConverter` - это вспомогательный класс для преобразования значений температуры, скорости ветра и давления в различные единицы измерения.
class UnitConverter {

    // MARK: - Temperature Conversion
    
    /// Преобразует температуру в выбранную единицу измерения.
    /// - Parameters:
    ///   - temp: Температура в Цельсиях.
    ///   - unit: Единица измерения (0 - Цельсий, 1 - Фаренгейт).
    /// - Returns: Преобразованное значение температуры как строка.
    static func convertTemperature(_ temp: Double, to unit: Int) -> String {
        switch unit {
        case 0: // Цельсий
            return "\(Int(temp))\(Constants.Strings.celsiusUnit)"
        case 1: // Фаренгейт
            let fahrenheit = (temp * 9/5) + 32
            return "\(Int(fahrenheit))\(Constants.Strings.fahrenheitUnit)"
        default:
            return "\(Int(temp))\(Constants.Strings.celsiusUnit)"
        }
    }
    
    // MARK: - Wind Speed Conversion
    
    /// Преобразует скорость ветра в выбранную единицу измерения.
    /// - Parameters:
    ///   - speed: Скорость ветра в метрах в секунду.
    ///   - unit: Единица измерения (0 - м/с, 1 - км/ч, 2 - миль/ч, 3 - узлы).
    /// - Returns: Преобразованное значение скорости ветра как строка.
    static func convertWindSpeed(_ speed: Double, to unit: Int) -> String {
        switch unit {
        case 0: // м/с
            return "\(Int(speed)) " + Constants.Strings.meterPerSecondUnit
        case 1: // км/ч
            let kmh = speed * 3.6
            return "\(Int(kmh)) " + Constants.Strings.kmPerHourUnit
        case 2: // миль/ч
            let mph = speed * 2.237
            return "\(Int(mph)) " + Constants.Strings.mphUnit
        case 3: // узлы
            let knots = speed * 1.944
            return "\(Int(knots)) " + Constants.Strings.knotsUnit
        default:
            return "\(Int(speed)) " + Constants.Strings.meterPerSecondUnit
        }
    }
    
    // MARK: - Pressure Conversion
    
    /// Преобразует давление в выбранную единицу измерения.
    /// - Parameters:
    ///   - pressure: Давление в гПа (гектопаскалях).
    ///   - unit: Единица измерения (0 - hPa, 1 - мм рт.ст., 2 - mbar, 3 - дюймы рт.ст.).
    /// - Returns: Преобразованное значение давления как строка.
    static func convertPressure(_ pressure: Double, to unit: Int) -> String {
        switch unit {
        case 0: // hPa
            return "\(Int(pressure)) " + Constants.Strings.hPaUnit
        case 1: // мм рт.ст.
            let mmHg = pressure * 0.75006375541921
            return "\(Int(mmHg)) " + Constants.Strings.mmHgUnit
        case 2: // mbar
            return "\(Int(pressure)) " + Constants.Strings.mbarUnit
        case 3: // дюймы рт.ст.
            let inHg = pressure * 0.02953
            return String(format: Constants.FormatStrings.twoDecimalFormat + Constants.Strings.emptyPlaceholder + Constants.Strings.inHgUnit, inHg)
        default:
            return "\(Int(pressure)) " + Constants.Strings.hPaUnit
        }
    }
}


