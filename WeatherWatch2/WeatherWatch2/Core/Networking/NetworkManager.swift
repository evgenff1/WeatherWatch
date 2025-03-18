//
//  NetworkManager.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import Foundation
import Alamofire

/// `NetworkManager` — это центральный компонент для выполнения сетевых запросов в приложении, связанных с данными о погоде и поиском городов.
/// Этот класс реализован как синглтон (singleton) для следующих целей:
/// - Экономия ресурсов: использование одного экземпляра `NetworkManager` предотвращает создание
///   дополнительных объектов для каждого сетевого запроса, оптимизируя память и ресурсы.
/// - Удобство использования: единый экземпляр `NetworkManager` предоставляет централизованный доступ
///   ко всем сетевым операциям, связанным с погодой и городами, по всему приложению.
/// - Безопасность данных: хранение API-ключа в приватной переменной в синглтоне гарантирует,
///   что доступ к ключу возможен только из класса `NetworkManager`.
///
/// Класс `NetworkManager` отвечает за создание URL для API-запросов, выполнение сетевых запросов, а также за обработку и возврат данных через замыкания.
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
    
    // MARK: - Fetch Weather Data
    
    /// Получение данных о погоде для указанных координат.
    /// - Parameters:
    ///   - latitude: Широта (географическая координата).
    ///   - longitude: Долгота (географическая координата).
    ///   - completion: Замыкание, возвращающее результат типа `Result`, содержащий либо успешный ответ `ForecastResponse`,
    ///     либо ошибку `AFError`.
    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<ForecastResponse, AFError>) -> Void) {
        // Создание URL для запроса данных о погоде; завершение с ошибкой, если URL не удалось создать
        guard let url = makeWeatherURL(latitude: latitude, longitude: longitude) else {
            let error = AFError.parameterEncodingFailed(reason: .missingURL)
            completion(.failure(error))
            return
        }
        
        // Используем responseDecodable для автоматического декодирования JSON в ForecastResponse
        AF.request(url)
            .validate() // Проверка HTTP-кодов (200...299)
            .responseDecodable(of: ForecastResponse.self) { response in
                completion(response.result)
            }
    }
    
    // MARK: - Search City
    
    /// Поиск города по введенному запросу.
    /// - Parameters:
    ///   - query: Строка запроса для поиска города.
    ///   - completion: Замыкание, возвращающее результат типа `Result`, содержащий либо массив `CitySearchResult`,
    ///     либо ошибку `AFError`.
    func searchCity(query: String, completion: @escaping (Result<[CitySearchResult], AFError>) -> Void) {
        // Создание URL для поиска города; завершение с ошибкой, если URL не удалось создать
        guard let url = makeSearchCityURL(query: query) else {
            let error = AFError.parameterEncodingFailed(reason: .missingURL)
            completion(.failure(error))
            return
        }
        
        AF.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let cities = try self.parseCitySearchResults(from: data)
                        completion(.success(cities))
                    } catch {
                        let afError = AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error))
                        completion(.failure(afError))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Parse City Search Results
    
    /// Разбирает JSON-ответ API поиска городов в массив объектов `CitySearchResult`.
    /// - Parameter data: Данные в формате JSON.
    /// - Returns: Массив объектов `CitySearchResult`.
    /// - Throws: Ошибки декодирования, если формат данных не соответствует ожидаемому.
    private func parseCitySearchResults(from data: Data) throws -> [CitySearchResult] {
        guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            throw NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
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
