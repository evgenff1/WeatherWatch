//
//  LocalizationHelper.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 13.09.2024.
//

import Foundation

/// `LocalizationHelper` предоставляет методы для работы с локализацией в приложении,
/// позволяя определить, какой язык активен, и возвращать наименования городов в соответствии с выбранным языком.
enum LocalizationHelper {
    
    // MARK: - Properties
    
    /// Свойство, определяющее, установлен ли язык приложения на русский.
    static var isRussian: Bool {
        return Bundle.main.preferredLocalizations.first == Constants.LocalizationKeys.ru
    }
    
    // MARK: - Методы локализации
    
    /// Возвращает локализованное название города на основе объекта `CityObject`.
    /// - Parameter cityObject: Объект, содержащий информацию о городе.
    /// - Returns: Локализованное название города, в зависимости от текущего языка.
    static func localizedCityName(cityObject: CityObject) -> String {
        if isRussian {
            return (cityObject.localNameRu?.isEmpty == false) ? cityObject.localNameRu! : cityObject.name
        } else {
            return (cityObject.localNameEn?.isEmpty == false) ? cityObject.localNameEn! : cityObject.name
        }
    }
    
    /// Возвращает локализованное название города на основе объекта `CitySearchResult`.
    /// - Parameter cityResult: Объект результата поиска, содержащий информацию о городе.
    /// - Returns: Локализованное название города, в зависимости от текущего языка.
    static func localizedCityName(cityResult: CitySearchResult) -> String {
        if isRussian {
            return !cityResult.localNameRu.isEmpty ? cityResult.localNameRu : cityResult.name
        } else {
            return !cityResult.localNameEn.isEmpty ? cityResult.localNameEn : cityResult.name
        }
    }
}
