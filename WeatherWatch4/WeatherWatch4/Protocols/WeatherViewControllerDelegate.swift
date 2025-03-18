//
//  WeatherViewControllerDelegate.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 10.09.2024.
//

import Foundation

/// Делегат для управления кэшированием городов и текущей страницей.
protocol WeatherViewControllerDelegate: AnyObject {
    
    // MARK: - Cache Management
    
    /// Удаление города из кэша.
    /// - Parameter cityId: Идентификатор города для удаления.
    func removeCityFromCache(cityId: String)
    
    // MARK: - Page Index
    
    /// Получение текущего индекса страницы.
    /// - Returns: Текущий индекс страницы.
    func getCurrentPageIndex() -> Int
}

