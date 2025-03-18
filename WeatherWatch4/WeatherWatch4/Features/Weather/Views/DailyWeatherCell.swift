//
//  DailyWeatherCell.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

/// Ячейка таблицы для отображения прогноза погоды на день
class DailyWeatherCell: UITableViewCell {
    
    // MARK: - Properties
    
    /// Метка для отображения даты прогноза
    private lazy var dateLabel: UILabel = {
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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupLayout()
    }
    
    /// Инициализатор с decoder'ом для инициализации через сториборд
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Subviews
    
    /// Метод для добавления всех подвидов в contentView ячейки
    private func setupSubviews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(iconImageView)
    }
    
    // MARK: - Layout
    
    /// Метод для настройки компоновки подвидов внутри ячейки
    private func setupLayout() {
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.buttonSize),
            temperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: temperatureLabel.trailingAnchor, constant: Constants.Dimensions.paddingSmall),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.iconSizeSmall),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.iconSizeSmall)
        ])
    }
    
    // MARK: - Configuration
    
    /// Метод для конфигурации ячейки с данными о погоде
    ///
    /// - Parameters:
    ///   - dailyForecast: Данные прогноза на день
    ///   - temperatureUnit: Единица измерения температуры (Цельсий, Фаренгейт и т.д.)
    func configure(with dailyForecast: DailyForecast, temperatureUnit: Int) {
        dateLabel.text = dailyForecast.date
        let minTemp = UnitConverter.convertTemperature(dailyForecast.temperatureMin, to: temperatureUnit)
        let maxTemp = UnitConverter.convertTemperature(dailyForecast.temperatureMax, to: temperatureUnit)
        temperatureLabel.text = "\(minTemp) - \(maxTemp)"
        
        Task { @MainActor in
            if let image = await IconCacheManager.shared.getIcon(for: dailyForecast.icon) {
                self.iconImageView.image = image
            }
        }
    }
}

