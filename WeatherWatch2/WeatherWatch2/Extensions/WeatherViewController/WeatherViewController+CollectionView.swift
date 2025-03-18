//
//  WeatherViewController+CollectionView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource Methods
    
    /// Количество элементов для отображения почасового прогноза.
    /// - Parameters:
    ///   - collectionView: Коллекция отображения
    ///   - section: Секция коллекции
    /// - Returns: Количество элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherViewModel.hourlyWeather.count
    }
    
    /// Создание и настройка ячейки с почасовым прогнозом.
    /// - Parameters:
    ///   - collectionView: Коллекция отображения
    ///   - indexPath: Путь к элементу в коллекции
    /// - Returns: Настроенная ячейка HourlyWeatherCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyWeatherCell.reuseIdentifier, for: indexPath) as? HourlyWeatherCell else {
            fatalError("Unable to dequeue HourlyWeatherCell")
        }
        let hourlyWeather = weatherViewModel.hourlyWeather[indexPath.item]
        cell.configure(with: hourlyWeather, temperatureUnit: weatherViewModel.temperatureUnit)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    
    /// Размер ячейки с почасовым прогнозом.
    /// - Parameters:
    ///   - collectionView: Коллекция отображения
    ///   - collectionViewLayout: Макет коллекции
    ///   - indexPath: Путь к элементу
    /// - Returns: Размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.Dimensions.collectionCellWidth, height: Constants.Dimensions.collectionCellHeight)
    }
}

