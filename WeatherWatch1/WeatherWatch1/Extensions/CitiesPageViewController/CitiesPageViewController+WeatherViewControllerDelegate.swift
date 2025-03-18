//
//  CitiesPageViewController+WeatherViewControllerDelegate.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 10.09.2024.
//

import Foundation

extension CitiesPageViewController: WeatherViewControllerDelegate {
    
    // MARK: - Cache Management
    
    /// Удаление города из кеша.
    /// - Parameter cityId: Идентификатор города для удаления из кеша.
    func removeCityFromCache(cityId: String) {
        weatherViewControllersCache.removeObject(forKey: cityId as NSString)
    }
    
    // MARK: - Page Index Retrieval
    
    /// Получение индекса текущей страницы.
    /// - Returns: Текущий индекс страницы в списке городов.
    func getCurrentPageIndex() -> Int {
        return citiesViewModel.currentIndex
    }
}

