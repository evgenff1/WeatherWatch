//
//  CitiesListViewControllerDelegate.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 04.09.2024.
//

/// Делегат для уведомления об обновлении списка городов и выборе города.
protocol CitiesListViewControllerDelegate: AnyObject {
    
    // MARK: - City Updates
    
    /// Уведомление об обновлении списка городов.
    /// - Parameter updatedCities: Обновленный массив объектов CityObject.
    func didUpdateCities(_ updatedCities: [CityObject])
    
    // MARK: - City Selection
    
    /// Уведомление о выборе города по индексу.
    /// - Parameter index: Индекс выбранного города.
    func didSelectCity(at index: Int)
}

