//
//  NetworkManager.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import Foundation

/// `NetworkManager` — это центральный компонент для выполнения сетевых запросов в приложении, связанных с данными о погоде и поиском городов.
/// Этот класс реализован как синглтон (singleton) для следующих целей:
/// - Экономия ресурсов: использование одного экземпляра `NetworkManager` предотвращает создание
///   дополнительных объектов для каждого сетевого запроса, оптимизируя память и ресурсы.
/// - Удобство использования: единый экземпляр `NetworkManager` предоставляет централизованный доступ
///   ко всем сетевым операциям, связанным с погодой и городами, по всему приложению.
/// - Безопасность данных: хранение API-ключа в приватной переменной в синглтоне гарантирует,
///   что доступ к ключу возможен только из класса `NetworkManager`.
///
/// Класс `NetworkManager` отвечает за создание URL для API-запросов, выполнение сетевых запросов, а также за обработку данных.
final class NetworkManager {
    
    // MARK: - Singleton Instance
    
    /// Статическое свойство, предоставляющее единый экземпляр `NetworkManager` для всего приложения.
    static let shared = NetworkManager()
    
    // MARK: - Private Properties
    
    /// Приватный API-ключ для доступа к сервису погоды. Извлекается из Info.plist.
    private let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: Constants.API.weatherAPIKey) as? String else {
            fatalError("API_KEY отсутствует в Info.plist")
        }
        return key
    }()
    
    /// Язык, используемый в запросах. Зависит от языка, выбранного пользователем в приложении.
    private let lang = LocalizationHelper.isRussian ? Constants.LocalizationKeys.ru : Constants.LocalizationKeys.en
    
    // MARK: - Initialization
    
    /// Приватный инициализатор, предотвращающий создание дополнительных экземпляров класса.
    private init() {}
    
    // MARK: - Network Request
    
    /// Выполняет сетевой запрос по заданному URL с использованием async/await.
    /// - Parameter url: URL, по которому выполняется запрос.
    /// - Returns: Данные, полученные от сервера.
    /// - Throws: Ошибки сети или HTTP ошибки, если запрос не успешен.
    private func performRequest(with url: URL) async throws -> Data {
        // Вызывает асинхронный метод `URLSession.shared.data(from:)`, который приостанавливает выполнение до получения ответа.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Проверяет, что HTTP-статус ответа находится в диапазоне 200...299.
        // В случае ошибки генерирует соответствующую ошибку (например, ошибка сети или HTTP ошибка).
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.error(from: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        return data
    }
    
    // MARK: - Fetch Weather Data
    
    /// Получает данные о погоде для заданных координат с использованием async/await.
    /// - Parameters:
    ///   - latitude: Широта местоположения.
    ///   - longitude: Долгота местоположения.
    /// - Returns: Объект `ForecastResponse` с информацией о погоде.
    /// - Throws: Ошибки, связанные с выполнением запроса или декодированием данных.
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> ForecastResponse {
        // Создаёт URL для запроса погоды.
        guard let url = makeWeatherURL(latitude: latitude, longitude: longitude) else {
            throw NetworkError.unknownError
        }
        
        // Вызывает `performRequest(with:)` для выполнения сетевого запроса.
        let data = try await performRequest(with: url)
        // Декодирует полученные JSON-данные в объект `ForecastResponse`.
        return try JSONDecoder().decode(ForecastResponse.self, from: data)
    }
    
    // MARK: - Search City
    
    /// Выполняет поиск города по введённому запросу с использованием async/await.
    /// - Parameter query: Строка запроса (например, имя города).
    /// - Returns: Массив объектов `CitySearchResult`.
    /// - Throws: Ошибки, связанные с выполнением запроса или декодированием данных.
    func searchCity(query: String) async throws -> [CitySearchResult] {
        // Формирует URL для запроса поиска города.
        guard let url = makeSearchCityURL(query: query) else {
            throw NetworkError.unknownError
        }
        
        // Вызывает `performRequest(with:)` для получения данных.
        let data = try await performRequest(with: url)
        // Парсит JSON-ответ в массив объектов `CitySearchResult`.
        return try parseCitySearchResults(from: data)
    }
    
    // MARK: - Parse City Search Results
    
    /// Разбирает JSON-ответ поиска городов в массив объектов `CitySearchResult`.
    ///
    /// - Parameter data: Данные в формате JSON.
    /// - Returns: Массив объектов `CitySearchResult`.
    /// - Throws: Ошибки декодирования, если формат данных не соответствует ожидаемому.
    private func parseCitySearchResults(from data: Data) throws -> [CitySearchResult] {
        guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            throw NetworkError.decodingError(description: "Invalid JSON format")
        }
        
        return jsonArray.compactMap { dict in
            guard let name = dict[Constants.JSONKeys.name] as? String,
                  let country = dict[Constants.JSONKeys.country] as? String,
                  let state = dict[Constants.JSONKeys.state] as? String,
                  let lat = dict[Constants.JSONKeys.lat] as? Double,
                  let lon = dict[Constants.JSONKeys.lon] as? Double,
                  let localNames = dict[Constants.JSONKeys.localNames] as? [String: String] else { return nil }
            
            return CitySearchResult(
                name: name,
                country: country,
                localNameEn: localNames[Constants.LocalizationKeys.en] ?? "",
                localNameRu: localNames[Constants.LocalizationKeys.ru] ?? "",
                state: state,
                latitude: lat,
                longitude: lon
            )
        }
    }
    
    // MARK: - URL Generation
    
    /// Создание URL для запроса погоды.
    /// - Parameters:
    ///   - latitude: Широта местоположения.
    ///   - longitude: Долгота местоположения.
    /// - Returns: Сформированный URL для запроса погоды, или `nil`, если URL не удалось создать.
    private func makeWeatherURL(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents()
        components.scheme = Constants.API.scheme
        components.host = Constants.API.host
        components.path = Constants.API.forecastPath
        components.queryItems = [
            URLQueryItem(name: Constants.API.latitudeParam, value: "\(latitude)"),
            URLQueryItem(name: Constants.API.longitudeParam, value: "\(longitude)"),
            URLQueryItem(name: Constants.API.apiKeyParam, value: apiKey),
            URLQueryItem(name: Constants.API.unitsParam, value: Constants.API.units),
            URLQueryItem(name: Constants.API.langParam, value: lang)
        ]
        return components.url
    }
    
    /// Создание URL для поиска города.
    /// - Parameters:
    ///   - query: Запрос поиска (имя города).
    /// - Returns: Сформированный URL для запроса поиска города, или `nil`, если URL не удалось создать.
    private func makeSearchCityURL(query: String) -> URL? {
        var components = URLComponents()
        components.scheme = Constants.API.scheme
        components.host = Constants.API.host
        components.path = Constants.API.geoPath
        components.queryItems = [
            URLQueryItem(name: Constants.API.queryParam, value: query),
            URLQueryItem(name: Constants.API.limitParam, value: Constants.API.resultLimit),
            URLQueryItem(name: Constants.API.apiKeyParam, value: apiKey),
            URLQueryItem(name: Constants.API.langParam, value: lang)
        ]
        return components.url
    }
}
