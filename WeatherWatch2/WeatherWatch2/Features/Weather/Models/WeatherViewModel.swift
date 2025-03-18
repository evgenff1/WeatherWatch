//
//  WeatherViewModel.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import Foundation
import RealmSwift

/// Модель представления погоды для работы с данными прогноза
class WeatherViewModel {
    
    // MARK: - Properties
    
    /// Массив почасового прогноза.
    var hourlyWeather: [HourlyForecast] = []
    
    /// Массив ежедневного прогноза.
    var dailyWeather: [DailyForecast] = []
    
    /// Ответ с данными прогноза, обновляет почасовой и ежедневный прогноз при изменении.
    var forecastResponse: ForecastResponse? {
        didSet {
            hourlyWeather = computeHourlyWeather()
            dailyWeather = computeDailyWeather()
            updateView?()
        }
    }
    
    /// Название города для отображения.
    var cityName: String = Constants.Strings.emptyPlaceholder
    
    /// Широта города.
    private var latitude: Double = 0.0
    
    /// Долгота города.
    private var longitude: Double = 0.0
    
    /// Уникальный идентификатор города.
    var cityId: ObjectId
    
    /// Замыкание для обновления представления.
    var updateView: (() -> Void)?
    
    /// Предыдущий ответ прогноза, используемый при ошибке обновления данных.
    private var previousForecastResponse: ForecastResponse?
    
    /// Единица измерения температуры.
    var temperatureUnit: Int {
        return SettingsManager.shared.temperatureUnit
    }
    
    /// Единица измерения скорости ветра.
    private var windSpeedUnit: Int {
        return SettingsManager.shared.windSpeedUnit
    }
    
    /// Единица измерения давления.
    private var pressureUnit: Int {
        return SettingsManager.shared.pressureUnit
    }
    
    // MARK: - Computed Properties
    
    /// Текущая температура с преобразованием в нужную единицу.
    var temperature: String {
        guard let temp = forecastResponse?.list.first?.main.temp else { return Constants.Strings.emptyPlaceholder }
        return UnitConverter.convertTemperature(temp, to: temperatureUnit)
    }

    /// Температура "ощущается как".
    var feelsLike: String {
        guard let feelsLike = forecastResponse?.list.first?.main.feelsLike else { return Constants.Strings.emptyPlaceholder }
        return Constants.Strings.feelsLike + Constants.Strings.emptyPlaceholder + UnitConverter.convertTemperature(feelsLike, to: temperatureUnit)
    }

    /// Скорость ветра с преобразованием в нужную единицу.
    var windSpeed: String {
        guard let windSpeed = forecastResponse?.list.first?.wind.speed else { return Constants.Strings.emptyPlaceholder }
        return Constants.Strings.wind + Constants.Strings.valueSeparator + UnitConverter.convertWindSpeed(windSpeed, to: windSpeedUnit)
    }

    /// Давление с преобразованием в нужную единицу.
    var pressure: String {
        guard let pressure = forecastResponse?.list.first?.main.pressure else { return Constants.Strings.emptyPlaceholder }
        return Constants.Strings.pressure + Constants.Strings.valueSeparator + UnitConverter.convertPressure(pressure, to: pressureUnit)
    }
    
    /// Описание погодных условий.
    var description: String {
        return forecastResponse?.list.first?.weather.first?.description ?? Constants.Strings.emptyPlaceholder
    }

    /// Влажность.
    var humidity: String {
        guard let humidity = forecastResponse?.list.first?.main.humidity else { return Constants.Strings.emptyPlaceholder }
        return Constants.Strings.humidity + Constants.Strings.valueSeparator + "\(humidity)" + Constants.Strings.percentageSymbol
    }
    
    /// Время восхода.
    var sunrise: String {
        guard let sunrise = forecastResponse?.city.sunrise,
              let timezone = forecastResponse?.city.timezone else { return Constants.Strings.emptyPlaceholder }
        let date = Date(timeIntervalSince1970: sunrise).applying(timezoneOffset: timezone)
        return Constants.Strings.sunrise + Constants.Strings.valueSeparator + "\(DateFormatterCache.shared.timeFormatter.string(from: date))"
    }
    
    /// Время заката.
    var sunset: String {
        guard let sunset = forecastResponse?.city.sunset,
              let timezone = forecastResponse?.city.timezone else { return Constants.Strings.emptyPlaceholder }
        let date = Date(timeIntervalSince1970: sunset).applying(timezoneOffset: timezone)
        return Constants.Strings.sunset + Constants.Strings.valueSeparator + "\(DateFormatterCache.shared.timeFormatter.string(from: date))"
    }
    
    // MARK: - Initializer
    
    /// Инициализация модели прогноза для указанного объекта города.
    /// - Parameter cityObject: Объект CityObject для получения данных города.
    init(cityObject: CityObject) {
        self.latitude = cityObject.latitude
        self.longitude = cityObject.longitude
        self.cityId = cityObject.id
        self.cityName = LocalizationHelper.localizedCityName(cityObject: cityObject)
    }
    
    // MARK: - Data Fetching
    
    /// Запрос данных прогноза погоды по текущим координатам.
    func fetchWeather() {
        NetworkManager.shared.fetchWeatherData(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let forecastData):
                    self?.previousForecastResponse = forecastData
                    self?.forecastResponse = forecastData
                case .failure:
                    // Если возникает ошибка, используем предыдущие данные прогноза
                    self?.forecastResponse = self?.previousForecastResponse
                }
            }
        }
    }
    
    // MARK: - Hourly Weather Computation
    
    /// Вычисление списка почасовых прогнозов погоды.
    /// - Returns: Массив объектов `HourlyForecast` с данными на каждый час.
    private func computeHourlyWeather() -> [HourlyForecast] {
        guard let list = forecastResponse?.list else { return [] }

        var hourlyForecasts = [HourlyForecast]()
        let now = Date()

        // Добавляем первый элемент с меткой "Now"
        if let firstItem = list.first {
            let hourlyForecast = createHourlyForecast(for: firstItem, timeLabel: Constants.Strings.hourlyNow)
            hourlyForecasts.append(hourlyForecast)
        }

        // Перебираем следующие 47 часов
        for hourOffset in Constants.Forecast.hourlyRange {
            if let forecast = createForecast(for: hourOffset, from: now, with: list) {
                hourlyForecasts.append(forecast)
            }
        }

        return hourlyForecasts
    }
    
    // MARK: - Helper Functions for Forecast Computation
    
    /// Создание прогноза на заданный час.
    /// - Parameters:
    ///   - hourOffset: Количество часов от текущего времени.
    ///   - now: Текущая дата.
    ///   - list: Список объектов `ForecastListItem` с данными погоды.
    /// - Returns: Объект `HourlyForecast` для заданного часа или nil, если не удалось создать прогноз.
    private func createForecast(for hourOffset: Int, from now: Date, with list: [ForecastListItem]) -> HourlyForecast? {
        let calendar = Calendar.current
        if var date = calendar.date(byAdding: .hour, value: hourOffset, to: now) {
            // Добавляем корректировку по часовому поясу
            if let timezone = forecastResponse?.city.timezone {
                date = date.applying(timezoneOffset: timezone)
            }
            guard let updatedDate = calendar.date(bySettingHour: calendar.component(.hour, from: date), minute: 0, second: 0, of: date) else {
                return nil
            }
            date = updatedDate
            
            // Поиск ближайших элементов прогноза до и после
            let previousItem = findClosestItem(before: date, in: list)
            let nextItem = findClosestItem(after: date, in: list)

            let (temp, icon) = interpolateTemperatureAndIcon(date: date, previousItem: previousItem, nextItem: nextItem)
            let timeString = formatTime(date: date)

            return HourlyForecast(time: timeString, temperature: temp, icon: icon)
        }
        return nil
    }

    // MARK: - Temperature and Icon Interpolation

    /// Интерполяция температуры и иконки для заданной даты.
    /// - Parameters:
    ///   - date: Дата, для которой нужна интерполяция.
    ///   - previousItem: Предыдущий элемент прогноза.
    ///   - nextItem: Следующий элемент прогноза.
    /// - Returns: Кортеж, содержащий интерполированную температуру и иконку.
    private func interpolateTemperatureAndIcon(date: Date, previousItem: ForecastListItem?, nextItem: ForecastListItem?) -> (Double, String) {
        guard let previousItem = previousItem else {
            return (nextItem?.main.temp ?? 0, nextItem?.weather.first?.icon ?? Constants.Strings.defaultIcon)
        }
        
        guard let nextItem = nextItem,
              let timezone = forecastResponse?.city.timezone,
              let previousDate = DateFormatterCache.shared.inputFormatter.date(from: previousItem.dateText)?.applying(timezoneOffset: timezone),
              let nextDate = DateFormatterCache.shared.inputFormatter.date(from: nextItem.dateText)?.applying(timezoneOffset: timezone) else {
            return (previousItem.main.temp, previousItem.weather.first?.icon ?? Constants.Strings.defaultIcon)
        }
        
        let fraction = date.timeIntervalSince(previousDate) / nextDate.timeIntervalSince(previousDate)
        let temp = previousItem.main.temp + fraction * (nextItem.main.temp - previousItem.main.temp)
        let icon = fraction > 0.5 ? nextItem.weather.first?.icon ?? Constants.Strings.defaultIcon : previousItem.weather.first?.icon ?? Constants.Strings.defaultIcon
        
        return (temp, icon)
    }
    
    // MARK: - Closest Item Search

    /// Нахождение ближайшего элемента прогноза до заданной даты.
    /// - Parameters:
    ///   - date: Дата, перед которой нужно найти элемент.
    ///   - list: Список элементов прогноза.
    /// - Returns: Элемент прогноза, если найден.
    private func findClosestItem(before date: Date, in list: [ForecastListItem]) -> ForecastListItem? {
        guard let timezone = forecastResponse?.city.timezone else { return nil }
        
        return list.last(where: {
            if let forecastDate = DateFormatterCache.shared.inputFormatter.date(from: $0.dateText)?.applying(timezoneOffset: timezone) {
                return forecastDate <= date
            }
            return false
        })
    }
    
    /// Нахождение ближайшего элемента прогноза после заданной даты.
    /// - Parameters:
    ///   - date: Дата, после которой нужно найти элемент.
    ///   - list: Список элементов прогноза.
    /// - Returns: Элемент прогноза, если найден.
    private func findClosestItem(after date: Date, in list: [ForecastListItem]) -> ForecastListItem? {
        guard let timezone = forecastResponse?.city.timezone else { return nil }
        
        return list.first(where: {
            if let forecastDate = DateFormatterCache.shared.inputFormatter.date(from: $0.dateText)?.applying(timezoneOffset: timezone) {
                return forecastDate > date
            }
            return false
        })
    }

    // MARK: - Time Formatting

    /// Форматирование времени для отображения.
    /// - Parameter date: Дата для форматирования.
    /// - Returns: Отформатированная строка времени.
    private func formatTime(date: Date) -> String {
        let timeString = DateFormatterCache.shared.timeFormatter.string(from: date)
        return timeString == Constants.Strings.timePlaceholder ? DateFormatterCache.shared.midnightFormatter.string(from: date) : timeString
    }

    // MARK: - Hourly Forecast Creation

    /// Создание почасового прогноза на основе данных.
    /// - Parameters:
    ///   - item: Элемент прогноза.
    ///   - timeLabel: Метка времени для прогноза.
    /// - Returns: Структура почасового прогноза.
    private func createHourlyForecast(for item: ForecastListItem, timeLabel: String) -> HourlyForecast {
        let temp = item.main.temp
        let icon = item.weather.first?.icon ?? Constants.Strings.defaultIcon
        return HourlyForecast(time: timeLabel, temperature: temp, icon: icon)
    }
    
    // MARK: - Daily Forecast Computation

    /// Создание списка прогноза на дни.
    /// - Returns: Массив дневных прогнозов.
    private func computeDailyWeather() -> [DailyForecast] {
        guard let list = forecastResponse?.list else { return [] }

        var dailyForecasts = [DailyForecast]()
        let dailyDictionary = groupForecastByDay(list)
        let sortedDailyKeys = dailyDictionary.keys.sorted()
        let selectedDays = sortedDailyKeys.prefix(5)

        for key in selectedDays {
            if let value = dailyDictionary[key], !value.isEmpty {
                let minTemp = findMinTemp(in: value)
                let maxTemp = findMaxTemp(in: value)
                let mostFrequentIcon = findMostFrequentIcon(in: value)
                let formattedDate = formatDate(from: key)

                let dailyForecast = DailyForecast(date: formattedDate, temperatureMin: minTemp, temperatureMax: maxTemp, icon: mostFrequentIcon)
                dailyForecasts.append(dailyForecast)
            }
        }

        return dailyForecasts
    }

    // MARK: - Forecast Grouping by Day

    /// Группировка прогноза по дням.
    /// - Parameter list: Список элементов прогноза.
    /// - Returns: Словарь, сгруппированный по дням.
    private func groupForecastByDay(_ list: [ForecastListItem]) -> [String: [ForecastListItem]] {
        return Dictionary(grouping: list) { item -> String in
            if let timezone = forecastResponse?.city.timezone,
               let date = DateFormatterCache.shared.inputFormatter.date(from: item.dateText)?.applying(timezoneOffset: timezone) {
                let datePart = DateFormatterCache.shared.keyFormatter.string(from: date)
                return String(datePart)
            }
            return item.dateText
        }
    }

    // MARK: - Temperature Calculations

    /// Нахождение минимальной температуры в прогнозе.
    /// - Parameter forecastItems: Список элементов прогноза.
    /// - Returns: Минимальная температура.
    private func findMinTemp(in forecastItems: [ForecastListItem]) -> Double {
        return forecastItems.map { $0.main.tempMin }.min() ?? 0
    }

    /// Нахождение максимальной температуры в прогнозе.
    /// - Parameter forecastItems: Список элементов прогноза.
    /// - Returns: Максимальная температура.
    private func findMaxTemp(in forecastItems: [ForecastListItem]) -> Double {
        return forecastItems.map { $0.main.tempMax }.max() ?? 0
    }

    // MARK: - Most Frequent Icon Finder

    /// Нахождение наиболее частой иконки в прогнозе.
    /// - Parameter forecastItems: Список элементов прогноза.
    /// - Returns: Иконка с наибольшей частотой.
    private func findMostFrequentIcon(in forecastItems: [ForecastListItem]) -> String {
        let dayIcons = forecastItems.compactMap { $0.weather.first?.icon }
        let iconFrequency = dayIcons.reduce(into: [:]) { counts, icon in counts[icon, default: 0] += 1 }
        return iconFrequency.max { $0.value < $1.value }?.key ?? Constants.Strings.defaultIcon
    }

    // MARK: - Date Formatting

    /// Форматирование строки даты.
    /// - Parameter key: Строка даты.
    /// - Returns: Отформатированная строка даты.
    private func formatDate(from key: String) -> String {
        let date = DateFormatterCache.shared.keyFormatter.date(from: key) ?? Date()
        return DateFormatterCache.shared.dayFormatter.string(from: date)
    }
    
}

