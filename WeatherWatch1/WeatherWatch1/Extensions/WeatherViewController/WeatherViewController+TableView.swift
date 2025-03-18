//
//  WeatherViewController+TableView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource Methods
    
    /// Количество строк в секции для ежедневного прогноза.
    /// - Parameters:
    ///   - tableView: Таблица отображения
    ///   - section: Секция таблицы
    /// - Returns: Количество строк в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherViewModel.dailyWeather.count
    }
    
    /// Создание и настройка ячейки с ежедневным прогнозом.
    /// - Parameters:
    ///   - tableView: Таблица отображения
    ///   - indexPath: Путь к строке
    /// - Returns: Настроенная ячейка DailyWeatherCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyWeatherCell.reuseIdentifier, for: indexPath) as? DailyWeatherCell else {
            fatalError("Unable to dequeue DailyWeatherCell")
        }
        let dailyWeather = weatherViewModel.dailyWeather[indexPath.row]
        cell.configure(with: dailyWeather, temperatureUnit: weatherViewModel.temperatureUnit)
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    /// Высота строки для ежедневного прогноза.
    /// - Parameters:
    ///   - tableView: Таблица отображения
    ///   - indexPath: Путь к строке
    /// - Returns: Высота строки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Dimensions.tableRowHeight
    }
}

