//
//  ForecastModels.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import Foundation

// MARK: - HourlyForecast Model

/// Модель почасового прогноза погоды.
struct HourlyForecast {
    /// Время прогноза в строковом формате.
    let time: String
    /// Температура на указанный час.
    let temperature: Double
    /// Иконка для отображения состояния погоды.
    let icon: String
}

// MARK: - DailyForecast Model

/// Модель дневного прогноза погоды.
struct DailyForecast {
    /// Дата прогноза в строковом формате.
    let date: String
    /// Минимальная температура на день.
    let temperatureMin: Double
    /// Максимальная температура на день.
    let temperatureMax: Double
    /// Иконка для отображения состояния погоды.
    let icon: String
}

