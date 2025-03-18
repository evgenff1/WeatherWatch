//
//  CoordinateMigrationManager.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 06.09.2024.
//

import Foundation
import RealmSwift

/// `DataUpdater` - это класс-синглтон, предназначенный для периодического обновления данных о городах,
/// включая географические координаты и локализованные названия.
///
/// Класс `DataUpdater` реализован как синглтон для обеспечения единого централизованного управления процессом обновления данных.
/// Преимущества использования синглтона в данном контексте включают:
/// - Управление ресурсами: Поскольку обновление данных о городах может требовать значительных ресурсов (например, сетевых запросов и операций записи в базу данных),
///   синглтон предотвращает создание нескольких экземпляров, которые могли бы вызывать конфликты при одновременном доступе к базе данных.
/// - Единая точка доступа: С помощью синглтона можно обращаться к `DataUpdater` из любой части приложения, упрощая вызов обновления данных.
/// - Упрощение асинхронной обработки данных: `DataUpdater` использует асинхронные операции и гарантирует, что все обновления выполняются последовательно и управляются единым объектом,
///   снижая вероятность ошибок.
final class DataUpdater {
    
    // MARK: - Singleton Instance
    
    /// Статический экземпляр `DataUpdater`, используемый для запуска процесса обновления городов.
    static let shared = DataUpdater()
    
    // MARK: - Initialization
    
    /// Приватный инициализатор для предотвращения создания других экземпляров `DataUpdater`.
    private init() {}

    // MARK: - Start Updating Cities
    
    /// Запускает процесс обновления городов.
    func startUpdatingCities() {
        guard let cities = RealmManager.shared.getCitiesWithoutCoordinatesOrNames(),
              !cities.isEmpty else { return }
        
        let citiesData = cities.map { (id: $0.id, name: $0.name) }
        
        // Запускаем обновление в фоновом потоке
        DispatchQueue.global(qos: .background).async {
            self.updateCitiesInBackground(cityData: citiesData)
        }
    }
    
    // MARK: - Update Cities in Background
    
    /// Обновляет города по переданным данным.
    /// - Parameter cityData: Массив кортежей, содержащих ObjectId и имя города.
    private func updateCitiesInBackground(cityData: [(ObjectId, String)]) {
        for (cityId, cityName) in cityData {
            // Выполняем сетевой запрос по имени города.
            NetworkManager.shared.searchCity(query: cityName) { result in
                switch result {
                case .success(let results):
                    guard let matchedCity = results.first else { return }
                    
                    // Обновление Realm в фоновом потоке с новым экземпляром Realm
                    DispatchQueue.global(qos: .background).async {
                        autoreleasepool {
                            do {
                                let realm = try Realm()
                                
                                // Ищем город по первичному ключу
                                if let city = realm.object(ofType: CityObject.self, forPrimaryKey: cityId) {
                                    try realm.write {
                                        city.latitude = matchedCity.latitude
                                        city.longitude = matchedCity.longitude
                                        city.localNameEn = matchedCity.localNameEn
                                        city.localNameRu = matchedCity.localNameRu
                                    }
                                    print("Updated city: \(city.name) with new coordinates: \(city.latitude), \(city.longitude)")
                                }
                            } catch {
                                print("Ошибка записи в Realm: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    print("Ошибка при поиске города: \(error.localizedDescription)")
                }
            }
        }
    }
}

