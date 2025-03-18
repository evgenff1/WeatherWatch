//
//  DateFormatterCache.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 01.09.2024.
//

import Foundation

/// Класс `DateFormatterCache` предназначен для хранения закэшированных форматтеров даты и времени,
/// используемых приложением.
///
/// Этот класс реализован как синглтон, чтобы обеспечить единый доступ к экземплярам
/// `DateFormatter` и избежать повторного создания форматтеров, что может быть ресурсоёмким.
///
/// - Important: Использование этого класса повышает производительность при работе с датами.
final class DateFormatterCache {
    
    // MARK: - Singleton Instance
    
    /// Единственный экземпляр (синглтон) для доступа к форматтерам
    static let shared = DateFormatterCache()
    
    // MARK: - Properties
    
    /// Флаг, определяющий, используется ли русский язык на основе локализации устройства.
    private let isRussian: Bool = LocalizationHelper.isRussian
    
    // MARK: - Initializer
    
    /// Приватный инициализатор для предотвращения создания дополнительных экземпляров класса.
    private init() {}
    
    // MARK: - Date Formatters
    
    /// Форматтер для полного формата даты и времени
    let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.fullDateTime
        return formatter
    }()
    
    /// Форматтер для времени (часы и минуты)
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.timeOnly
        return formatter
    }()
    
    /// Форматтер для даты, представляющей полночь (день и месяц)
    let midnightFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.dayMonth
        return formatter
    }()
    
    /// Форматтер для полного дня недели, месяца и числа
    lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.weekdayAndDate
        return formatter
    }()
    
    /// Форматтер для ключа даты (только год, месяц, день)
    let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.dayKey
        return formatter
    }()
}

