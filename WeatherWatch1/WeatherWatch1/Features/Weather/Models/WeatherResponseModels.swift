//
//  WeatherResponseModels.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

// MARK: - Forecast Models

/// Модель ответа с прогнозом.
struct ForecastResponse: Codable {
    let city: City
    let list: [ForecastListItem]
}

/// Модель города.
struct City: Codable {
    let name: String
    let timezone: Int
    let sunrise: Double
    let sunset: Double
}

// MARK: - Forecast List Item

/// Элемент списка прогноза.
struct ForecastListItem: Codable {
    let main: Main
    let weather: [Weather]
    let dateText: String
    let wind: Wind

    enum CodingKeys: String, CodingKey {
        case main
        case weather
        case dateText = "dt_txt"
        case wind
    }
}

// MARK: - Weather

/// Модель погоды с иконкой и описанием.
struct Weather: Codable {
    let icon: String
    let description: String
}

// MARK: - Weather Response

/// Ответ с информацией о погоде.
struct WeatherResponse: Codable {
    let name: String
    let main: Main
}

// MARK: - Main Weather Details

/// Основные параметры погоды.
struct Main: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let feelsLike: Double
    let humidity: Int
    let pressure: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case feelsLike = "feels_like"
        case humidity
        case pressure
    }
}

// MARK: - Wind

/// Модель ветра.
struct Wind: Codable {
    let speed: Double
}

// MARK: - City Search Result

/// Результат поиска города.
struct CitySearchResult {
    let name: String
    let country: String
    let localNameEn: String
    let localNameRu: String
    let state: String
    let latitude: Double
    let longitude: Double
}
