//
//  HourlyWeatherCell.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

/// Ячейка коллекции для отображения почасового прогноза
class HourlyWeatherCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// Метка для отображения времени
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Метка для отображения температуры
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Изображение для отображения иконки погоды
    private lazy var iconImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - Initialization
    
    /// Основной инициализатор ячейки
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
    }
    
    /// Инициализатор с decoder'ом для инициализации через сториборд
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Subviews
    
    /// Метод для добавления и настройки всех подвидов
    private func setupSubviews() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(iconImageView)
    }
    
    // MARK: - Layout
    
    /// Метод для настройки компоновки всех подвидов в ячейке
    private func setupLayout() {
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.iconSizeSmall),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.iconSizeSmall),

            temperatureLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    /// Метод для конфигурации ячейки с данными о погоде
    ///
    /// - Parameters:
    ///   - hourlyForecast: Данные почасового прогноза
    ///   - temperatureUnit: Единица измерения температуры (Цельсий, Фаренгейт и т.д.)
    func configure(with hourlyForecast: HourlyForecast, temperatureUnit: Int) {
        timeLabel.text = hourlyForecast.time
        temperatureLabel.text = UnitConverter.convertTemperature(hourlyForecast.temperature, to: temperatureUnit)
        
        IconCacheManager.shared.getIcon(for: hourlyForecast.icon) { [weak self] image in
            self?.iconImageView.image = image
        }
    }

}

