//
//  CitiesViewModel.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import Foundation

/// ViewModel для управления списком городов
class CitiesViewModel {
    
    // MARK: - Properties
    
    /// Массив объектов городов
    var cities: [CityObject]
    
    /// Индекс текущего выбранного города
    var currentIndex: Int = 0
    
    /// Текущий выбранный город
    var currentCity: CityObject {
        return cities[currentIndex]
    }
    
    /// Количество городов в списке
    var numberOfCities: Int {
        return cities.count
    }
    
    // MARK: - Initializer
    
    /// Инициализатор ViewModel
    init() {
        let cities = RealmManager.shared.getCities()
        self.cities = cities ?? []
    }
    
    // MARK: - Methods
    
    /// Устанавливает текущий индекс города
    /// - Parameter index: Индекс города, который будет установлен текущим
    func setCurrentCityIndex(to index: Int) {
        guard index >= 0 && index < cities.count else { return }
        currentIndex = index
        saveLastSelectedCity()
    }
    
    /// Сохраняет последний выбранный город
    private func saveLastSelectedCity() {
        RealmManager.shared.saveLastSelectedCity(currentCity)
    }
    
    /// Метод для получения города по индексу
    /// - Parameter index: Индекс города, который необходимо получить
    /// - Returns: Объект города, если индекс существует, или nil, если индекс невалиден
    func city(at index: Int) -> CityObject? {
        guard index >= 0 && index < cities.count else { return nil }
        return cities[index]
    }
    
}
