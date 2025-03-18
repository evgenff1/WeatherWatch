//
//  LocationManager.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 06.09.2024.
//

import CoreLocation

/// Класс `LocationManager` управляет доступом к данным о текущем местоположении пользователя
/// и предоставляет обновления местоположения для приложения.
///
/// Этот класс реализован как синглтон (singleton) для централизованного управления геолокацией,
/// поскольку:
/// - Существует единственный экземпляр `CLLocationManager`, который использует системные ресурсы
///   для получения данных о местоположении.
/// - Синглтон позволяет избежать дублирования запросов и данных о местоположении, гарантируя
///   обновления в едином потоке для всех компонентов приложения.
/// - Это позволяет легко управлять авторизацией и обработкой ошибок при доступе к геолокации.
///
/// `LocationManager` отправляет данные о местоположении и ошибки через замыкания `onLocationUpdate` и
/// `onLocationError`, что делает его удобным для работы с интерфейсом и асинхронной обработкой.
final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Singleton Instance
    
    /// Единственный экземпляр (синглтон) `LocationManager`.
    static let shared = LocationManager()
    
    // MARK: - Properties
    
    /// Основной экземпляр `CLLocationManager` для работы с геолокацией.
    private let locationManager = CLLocationManager()
    
    /// Замыкание для передачи обновлений местоположения (включая информацию о текущем городе).
    var onLocationUpdate: ((CityObject) -> Void)?
    
    /// Замыкание для обработки ошибок, связанных с доступом к геолокации.
    var onLocationError: ((Error) -> Void)?
    
    // MARK: - Initializer
    
    /// Приватный инициализатор предотвращает создание дополнительных экземпляров.
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Location Request
    
    /// Запрашивает текущую локацию пользователя. Проверяет статус авторизации и, если требуется,
    /// запрашивает разрешение. В случае наличия доступа к локации начинает обновление местоположения.
    func requestLocation() {
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            // Запрашиваем разрешение у пользователя
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Разрешение получено ранее, начинаем обновлять местоположение
            locationManager.startUpdatingLocation()
        } else {
            // Разрешение не предоставлено, обработка ошибки
            onLocationError?(NSError(domain: "Location", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location access denied"]))
        }
    }
    
    // MARK: - Location Handling
    
    /// Обрабатывает обновление местоположения, определяя новый город пользователя.
    /// - Parameter location: Новый объект `CLLocation`, представляющий текущее местоположение пользователя.
    private func handleLocationUpdate(location: CLLocation) {
        Task { @MainActor in
            if let currentCity = RealmManager.shared.getCurrentLocationCity() {
                if isLocationDifferentFromCurrentCity(currentCity: currentCity, newLocation: location) {
                    await fetchAndUpdateCityData(for: location, currentCity: currentCity)
                }
            } else {
                await fetchAndUpdateCityData(for: location, currentCity: nil)
            }
        }
    }
    
    /// Загружает данные о городе по координатам и обновляет текущий объект города в базе данных.
    /// - Parameters:
    ///   - location: Объект `CLLocation`, представляющий координаты пользователя.
    ///   - currentCity: Текущий город пользователя (если определен), который нужно обновить.
    @MainActor
    private func fetchAndUpdateCityData(for location: CLLocation, currentCity: CityObject?) async {
        do {
            // Первый запрос: асинхронно получаем данные о погоде и основное имя города
            let forecastResponse = try await NetworkManager.shared.fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let cityName = forecastResponse.city.name
            
            guard !cityName.isEmpty else {
                // Завершение, если имя города отсутствует
                return
            }
            
            // Второй запрос: асинхронно получаем локализованные названия через searchCity
            let cityResults = try await NetworkManager.shared.searchCity(query: cityName)
            // Находим первый результат, удовлетворяющий условию близости
            let matchedCity = cityResults.first { result in
                LocationManager.shared.isWithinDistance(
                    lat1: result.latitude,
                    lon1: result.longitude,
                    lat2: location.coordinate.latitude,
                    lon2: location.coordinate.longitude,
                    maxDistanceInMeters: Constants.Location.maxDistance // 10 км
                )
            }
            // Извлекаем локализованные имена, если они существуют
            let localNameEn = matchedCity?.localNameEn ?? ""
            let localNameRu = matchedCity?.localNameRu ?? ""
            
            if let currentCity = currentCity {
                // Обновляем существующий город
                RealmManager.shared.updateCity(
                    currentCity,
                    with: cityName,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    localNameEn: localNameEn,
                    localNameRu: localNameRu
                )
                RealmManager.shared.updateCurrentLocationFlag(for: currentCity)
                
                // Уведомление об обновлении
                self.onLocationUpdate?(currentCity)
                
            } else {
                // Создаем новый объект CityObject
                let newCity = CityObject(
                    name: cityName,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    localNameEn: localNameEn,
                    localNameRu: localNameRu,
                    isCurrentLocation: true
                )
                RealmManager.shared.addCity(newCity)
                RealmManager.shared.updateCurrentLocationFlag(for: newCity)
                
                // Уведомление об обновлении
                self.onLocationUpdate?(newCity)
            }
        } catch {
            print("Ошибка при обновлении данных города: \(error)")
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    /// Обрабатывает изменения статуса авторизации для доступа к местоположению.
    ///
    /// - Parameters:
    ///   - manager: Экземпляр `CLLocationManager`, ответственный за управление доступом к геолокации.
    ///   - status: Новый статус авторизации (`CLAuthorizationStatus`), указывающий, предоставлен ли доступ к местоположению.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Если доступ к геолокации предоставлен, начинаем обновлять местоположение
            locationManager.startUpdatingLocation()
        } else if status == .denied {
            // Если доступ не предоставлен, вызываем замыкание для обработки ошибки
            onLocationError?(NSError(domain: "Location", code: 1, userInfo: [NSLocalizedDescriptionKey: "Доступ к местоположению запрещен"]))
        }
    }
    
    /// Обрабатывает новые данные о местоположении, полученные от `CLLocationManager`.
    ///
    /// - Parameters:
    ///   - manager: Экземпляр `CLLocationManager`, который сообщает о новых данных местоположения.
    ///   - locations: Массив объектов `CLLocation`, представляющий последние данные о местоположении.
    ///   Используется только первый элемент массива.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Вызываем метод для обработки и обновления информации о городе на основе местоположения
            handleLocationUpdate(location: location)
            // Останавливаем обновление местоположения после получения первых данных
            locationManager.stopUpdatingLocation()
        }
    }
    
    /// Проверяет, отличается ли текущее местоположение от сохраненного местоположения города.
    ///
    /// - Parameters:
    ///   - currentCity: Объект `CityObject`, представляющий текущий сохраненный город.
    ///   - newLocation: Новый объект `CLLocation`, представляющий текущее местоположение.
    /// - Returns: Булево значение, указывающее, отличается ли текущее местоположение
    /// от сохраненного местоположения города на заданное расстояние.
    private func isLocationDifferentFromCurrentCity(currentCity: CityObject, newLocation: CLLocation) -> Bool {
        return !LocationManager.shared.isWithinDistance(
            lat1: currentCity.latitude,
            lon1: currentCity.longitude,
            lat2: newLocation.coordinate.latitude,
            lon2: newLocation.coordinate.longitude,
            maxDistanceInMeters: Constants.Location.maxDistance
        )
    }
    
    /// Обрабатывает ошибки, возникшие при попытке получения данных о местоположении.
    ///
    /// - Parameters:
    ///   - manager: Экземпляр `CLLocationManager`, ответственный за работу с геолокацией.
    ///   - error: Объект ошибки, возникшей при попытке определения местоположения.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Вызываем замыкание обработки
        onLocationError?(error)
    }
}



