//
//  RealmManager.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 05.09.2024.
//

import RealmSwift
import Foundation

// MARK: - CityObject Class

class CityObject: Object {
    /// Уникальный идентификатор объекта CityObject.
    @Persisted(primaryKey: true) var id: ObjectId
    /// Название города.
    @Persisted var name: String = ""
    /// Широта города (географические координаты).
    @Persisted var latitude: Double = 0.0
    /// Долгота города (географические координаты).
    @Persisted var longitude: Double = 0.0
    /// Порядковый номер города в списке (для сортировки).
    @Persisted var order: Int = 0
    /// Флаг, указывающий является ли город текущим местоположением пользователя.
    @Persisted var isCurrentLocation: Bool = false
    /// Название города на английском
    @Persisted var localNameEn: String? = nil
    /// Название города на русском
    @Persisted var localNameRu: String? = nil
    
    // MARK: - Initialization
    
    /// Инициализация города с названием, координатами и флагом текущего местоположения.
    /// - Parameters:
    ///   - name: Название города
    ///   - latitude: Широта города
    ///   - longitude: Долгота города
    ///   - localNameEn: Название города на английском
    ///   - localNameRu: Название города на русском
    ///   - isCurrentLocation: Флаг, указывающий является ли город текущим местоположением пользователя
    convenience init(name: String, latitude: Double, longitude: Double, localNameEn: String, localNameRu: String, isCurrentLocation: Bool = false) {
        self.init()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.localNameEn = localNameEn
        self.localNameRu = localNameRu
        self.isCurrentLocation = isCurrentLocation
        self.order = 0
    }
}

// MARK: - RealmManager Singleton

/// `RealmManager` управляет всеми операциями взаимодействия с базой данных Realm в приложении,
/// включая чтение, запись и обновление данных о городах.
/// Этот класс реализован как синглтон (singleton) для следующих целей:
/// - Сохранение ресурсов: использование одного экземпляра `RealmManager` предотвращает
///   создание множества объектов Realm, что экономит память и ресурсы.
/// - Централизация данных: все операции с базой данных выполняются через один и тот же экземпляр,
///   что упрощает поддержку целостности данных.
/// - Упрощенное управление: это обеспечивает централизованный доступ к данным приложения,
///   упрощает отладку и поддержку.
/// - `RealmManager` хранит экземпляр `Realm` и предоставляет методы для работы с данными о городах.
final class RealmManager {
    
    // MARK: - Singleton Instance
    
    /// Статическое свойство, которое создает и предоставляет общий экземпляр (синглтон) класса RealmManager.
    /// Это позволяет использовать один и тот же объект RealmManager во всем приложении, избегая создания новых экземпляров.
    static let shared = RealmManager()
    
    // MARK: - Properties
    
    /// Приватное свойство, хранящее ссылку на объект Realm, через который происходит взаимодействие с базой данных.
    /// Инициализируется как опциональное значение, так как в момент создания экземпляра RealmManager база данных может быть еще не настроена
    /// или может произойти ошибка при инициализации Realm (например, при миграции схемы). Это свойство приватное,
    /// чтобы доступ к базе данных был возможен только через методы класса RealmManager.
    private var realm: Realm?
    
    // MARK: - Initialization
    
    /// Приватный инициализатор, выполняющий настройку и конфигурацию `Realm`.
    /// Это предотвращает создание дополнительных экземпляров `RealmManager` за пределами этого класса.
    private init() {
        // Конфигурация Realm с миграцией
        let config = Realm.Configuration(
            schemaVersion: Constants.Realm.schemaVersion , // Новая версия схемы
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // Миграция на версию 2: добавляем поле 'order'
                    migration.enumerateObjects(ofType: CityObject.className()) { oldObject, newObject in
                        if let newObject = newObject {
                            newObject[Constants.Realm.orderDescriptors] = 0 // Значение по умолчанию для order
                        }
                    }
                }
                
                if oldSchemaVersion < 3 {
                    // Миграция на версию 3: добавляем поля 'latitude' и 'longitude'
                    migration.enumerateObjects(ofType: CityObject.className()) { oldObject, newObject in
                        if let newObject = newObject {
                            newObject[Constants.Realm.latitudeDescriptors] = 0.0 // Значение по умолчанию для широты
                            newObject[Constants.Realm.longitudeDescriptors] = 0.0 // Значение по умолчанию для долготы
                        }
                    }
                }
                
                if oldSchemaVersion < 4 {
                    // Миграция на версию 4: добавляем поле 'isCurrentLocation'
                    migration.enumerateObjects(ofType: CityObject.className()) { oldObject, newObject in
                        if let newObject = newObject {
                            newObject[Constants.Realm.isCurrentLocationDescriptors] = false
                        }
                    }
                }
                
                if oldSchemaVersion < 5 {
                    // Миграция на версию 5: добавляем поля 'localNameEn' и 'localNameRu'
                    migration.enumerateObjects(ofType: CityObject.className()) { oldObject, newObject in
                        if let newObject = newObject {
                            newObject[Constants.Realm.localNameEnDescriptors] = ""
                            newObject[Constants.Realm.localNameRuDescriptors] = ""
                        }
                    }
                }
                
                if oldSchemaVersion < 6 {
                    migration.enumerateObjects(ofType: CityObject.className()) { _, newObject in
                        if let newObject = newObject {
                            newObject[Constants.Realm.localNameEnDescriptors] = nil
                            newObject[Constants.Realm.localNameRuDescriptors] = nil
                        }
                    }
                }
                
            }
        )
        
        // Устанавливаем конфигурацию Realm с миграцией
        Realm.Configuration.defaultConfiguration = config
        
        do {
            // Попытка инициализировать Realm.
            // Если все настроено корректно, будет получена ссылка на базу данных.
            realm = try Realm()
        } catch let error {
            // Если происходит ошибка при инициализации (например, из-за конфигурации или миграции), приложение аварийно завершает работу.
            fatalError("Error initializing Realm: \(error)")
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Добавление нового города в базу данных Realm.
    /// - Parameter cityName: Экземпляр объекта CityObject для добавления в базу данных.
    func addCity(_ cityName: CityObject) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(cityName)
            }
        } catch {
            print("Error adding city: \(error)")
        }
    }
    
    /// Удаление города из базы данных Realm.
    /// - Parameter city: Экземпляр объекта CityObject для удаления.
    func deleteCity(_ city: CityObject) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.delete(city)
            }
        } catch {
            print("Error deleting city: \(error)")
        }
    }
    
    /// Обновление информации о городе.
    /// - Parameters:
    ///   - city: Объект CityObject для обновления.
    ///   - newName: Новое название города.
    ///   - latitude: Новая широта города.
    ///   - longitude: Новая долгота города.
    ///   - localNameEn: Новое наименование en
    ///   - localNameRu: Новое наименование ru
    func updateCity(_ city: CityObject, with newName: String, latitude: Double, longitude: Double, localNameEn: String, localNameRu: String) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                city.name = newName
                city.latitude = latitude
                city.longitude = longitude
                city.localNameEn = localNameEn
                city.localNameRu = localNameRu
            }
        } catch {
            print("Error updating city: \(error)")
        }
    }
    
    // MARK: - Data Management
    
    /// Получение списка городов с сортировкой по текущему местоположению и порядку.
    /// - Returns: Массив объектов CityObject или nil, если доступ к базе данных не был получен.
    func getCities() -> [CityObject]? {
        guard let realm = realm else { return nil }
        let cities = realm.objects(CityObject.self)
            .sorted(by: [
                SortDescriptor(keyPath: Constants.Realm.isCurrentLocationDescriptors, ascending: false), // Сначала города с текущим местоположением
                SortDescriptor(keyPath: Constants.Realm.orderDescriptors, ascending: true) // Затем по порядку
            ])
        return Array(cities)
    }
    
    /// Обновление порядка городов.
    /// - Parameter cities: Массив объектов CityObject для обновления порядка.
    func updateCityOrder(_ cities: [CityObject]) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                for (index, city) in cities.enumerated() {
                    city.order = index
                }
            }
        } catch {
            print("Error updating city order: \(error)")
        }
    }
    
    /// Обновление координат города.
    /// - Parameters:
    ///   - city: Объект CityObject для обновления координат.
    ///   - latitude: Новая широта.
    ///   - longitude: Новая долгота.
    func updateCityCoordinates(_ city: CityObject, latitude: Double, longitude: Double) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                city.latitude = latitude
                city.longitude = longitude
            }
        } catch {
            print("Error updating city coordinates: \(error)")
        }
    }
    
    /// Обновление флага текущего местоположения для заданного города.
    /// - Parameter currentCity: Объект CityObject, который станет текущим местоположением.
    func updateCurrentLocationFlag(for currentCity: CityObject) {
        guard let realm = realm else { return }
        let cities = realm.objects(CityObject.self).filter(Constants.Realm.currentLocationQuery)
        do {
            try realm.write {
                cities.forEach { $0.isCurrentLocation = false }
                currentCity.isCurrentLocation = true
            }
        } catch {
            print("Error updating current location flag: \(error)")
        }
    }
    
    /// Получение города с текущим местоположением.
    /// - Returns: Объект CityObject или nil, если текущий город не найден.
    func getCurrentLocationCity() -> CityObject? {
        guard let realm = realm else { return nil }
        return realm.objects(CityObject.self).filter(Constants.Realm.currentLocationQuery).first
    }
    
    /// Сохранение последнего выбранного города в UserDefaults.
    /// - Parameter city: Объект CityObject для сохранения.
    func saveLastSelectedCity(_ city: CityObject) {
        UserDefaults.standard.set(city.id.stringValue, forKey: Constants.UserDefaultsKeys.lastSelectedCityId)
    }
    
    /// Получение последнего выбранного города из UserDefaults.
    /// - Returns: Объект CityObject или nil, если сохраненный город не найден.
    func getLastSelectedCity() -> CityObject? {
        guard let lastCityId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.lastSelectedCityId),
              let objectId = try? ObjectId(string: lastCityId),
              let _ = realm else {
            return nil
        }
        return findCityById(objectId)
    }
    
    /// Поиск города по идентификатору.
    /// - Parameter id: Идентификатор объекта CityObject.
    /// - Returns: Объект CityObject или nil, если город не найден.
    private func findCityById(_ id: ObjectId) -> CityObject? {
        guard let realm = realm else { return nil }
        return realm.object(ofType: CityObject.self, forPrimaryKey: id)
    }
    
    /// Поиск города по координатам.
    /// - Parameters:
    ///   - latitude: Широта города.
    ///   - longitude: Долгота города.
    /// - Returns: Объект CityObject или nil, если город с такими координатами не найден.
    func findCityByCoordinates(_ latitude: Double, _ longitude: Double) -> CityObject? {
        guard let realm = realm else { return nil }
        let cities = realm.objects(CityObject.self)
        return cities.first { city in
            LocationManager.shared.isWithinDistance(
                lat1: city.latitude,
                lon1: city.longitude,
                lat2: latitude,
                lon2: longitude,
                maxDistanceInMeters: Constants.Location.maxDistance // 10 км
            )
        }
    }
    
    // MARK: - Migration Helpers
    
    /// Получение списка городов с пустыми координатами или пустым локальными наименованиями
    /// - Returns: Массив объектов CityObject с координатами (0, 0) или пустыми наименованиями или nil, если доступ к базе данных не был получен.
    func getCitiesWithoutCoordinatesOrNames() -> [CityObject]? {
        guard let realm = realm else { return nil }
        let cities = realm.objects(CityObject.self).filter(Constants.Realm.cityWithoutCoordinatesOrNamesQuery)
        return Array(cities)
    }
    
}


