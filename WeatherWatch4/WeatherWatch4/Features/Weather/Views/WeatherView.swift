//
//  WeatherView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

/// Основной вид для отображения информации о погоде
class WeatherView: UIView {
    
    // MARK: - Subviews
    
    /// Прокручиваемый контейнер для основного контента.
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    /// Основной вид для размещения подвидов в scrollView.
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Лейбл для отображения названия города.
    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Constants.Fonts.cityTitle
        return label
    }()
    
    /// Лейбл для отображения температуры.
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Constants.Fonts.temperature
        return label
    }()
    
    /// Лейбл для отображения текстового описания погоды.
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    /// Лейбл для отображения температуры "ощущается как".
    lazy var feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    /// Коллекция для отображения почасового прогноза погоды.
    lazy var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HourlyWeatherCell.self, forCellWithReuseIdentifier: HourlyWeatherCell.reuseIdentifier)
        return collectionView
    }()
    
    /// Таблица для отображения прогноза на несколько дней.
    lazy var dailyTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false
        table.isUserInteractionEnabled = false
        table.register(DailyWeatherCell.self, forCellReuseIdentifier: DailyWeatherCell.reuseIdentifier)
        return table
    }()
    
    /// Изображение для иконки погоды.
    lazy var weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Labels for Additional Information
    
    /// Лейбл для отображения времени восхода солнца.
    lazy var sunriseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = Constants.Fonts.smallDetails
        return label
    }()
    
    /// Лейбл для отображения времени заката солнца.
    lazy var sunsetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = Constants.Fonts.smallDetails
        return label
    }()
    
    /// Лейбл для отображения скорости ветра.
    let windLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Fonts.smallDetails
        return label
    }()
    
    /// Лейбл для отображения уровня влажности.
    lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Fonts.smallDetails
        return label
    }()
    
    /// Лейбл для отображения уровня давления.
    lazy var pressureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Fonts.smallDetails
        return label
    }()
    
    // MARK: - Containers for Layout

    /// Контейнер для отображения времени восхода и заката солнца.
    private lazy var sunTimesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.lightGrayWithAlpha
        view.layer.cornerRadius = Constants.Layout.cornerRadius
        return view
    }()
    
    /// Горизонтальный стек для лейблов времени восхода и заката солнца.
    private lazy var horizontalStackSunTimes: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = Constants.Layout.largeEdgeInsets
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    /// Контейнер для отображения дополнительных деталей о погоде.
    private lazy var weatherDetailsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.lightGrayWithAlpha
        view.layer.cornerRadius = Constants.Layout.cornerRadius
        return view
    }()
    
    /// Горизонтальный стек для дополнительных деталей о погоде.
    private lazy var horizontalStackWeatherDetails: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = Constants.Layout.smallEdgeInsets
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    // MARK: - Initializers
    
    /// Инициализатор вида WeatherView.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
    }
    
    /// Инициализатор, необходимый для загрузки из Storyboard.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// Настройка всех подвидов.
    private func setupSubviews() {
        addSubview(cityLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(weatherIconImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(feelsLikeLabel)
        contentView.addSubview(sunTimesContainer)
        sunTimesContainer.addSubview(horizontalStackSunTimes)
        horizontalStackSunTimes.addArrangedSubview(sunriseLabel)
        horizontalStackSunTimes.addArrangedSubview(sunsetLabel)
        contentView.addSubview(weatherDetailsContainer)
        weatherDetailsContainer.addSubview(horizontalStackWeatherDetails)
        horizontalStackWeatherDetails.addArrangedSubview(windLabel)
        horizontalStackWeatherDetails.addArrangedSubview(humidityLabel)
        horizontalStackWeatherDetails.addArrangedSubview(pressureLabel)
        contentView.addSubview(hourlyCollectionView)
        contentView.addSubview(dailyTableView)
    }
    
    /// Настройка всех ограничений компоновки.
    private func setupLayout() {
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.Dimensions.cityLabelTopMargin),
            cityLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Dimensions.scrollViewBottomMargin),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            temperatureLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.cityLabelTopMargin),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            weatherIconImageView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor),
            weatherIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.iconSizeMedium),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.iconSizeMedium),

            descriptionLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),

            feelsLikeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            feelsLikeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            sunTimesContainer.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            sunTimesContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            sunTimesContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            sunTimesContainer.heightAnchor.constraint(equalToConstant: Constants.Dimensions.sunTimesContainerHeight),

            horizontalStackSunTimes.leadingAnchor.constraint(equalTo: sunTimesContainer.leadingAnchor),
            horizontalStackSunTimes.trailingAnchor.constraint(equalTo: sunTimesContainer.trailingAnchor),
            horizontalStackSunTimes.topAnchor.constraint(equalTo: sunTimesContainer.topAnchor),
            horizontalStackSunTimes.bottomAnchor.constraint(equalTo: sunTimesContainer.bottomAnchor),

            weatherDetailsContainer.topAnchor.constraint(equalTo: sunTimesContainer.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherDetailsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            weatherDetailsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            weatherDetailsContainer.heightAnchor.constraint(equalToConstant: Constants.Dimensions.weatherDetailsContainerHeight),

            horizontalStackWeatherDetails.leadingAnchor.constraint(equalTo: weatherDetailsContainer.leadingAnchor),
            horizontalStackWeatherDetails.trailingAnchor.constraint(equalTo: weatherDetailsContainer.trailingAnchor),
            horizontalStackWeatherDetails.topAnchor.constraint(equalTo: weatherDetailsContainer.topAnchor),
            horizontalStackWeatherDetails.bottomAnchor.constraint(equalTo: weatherDetailsContainer.bottomAnchor),

            hourlyCollectionView.topAnchor.constraint(equalTo: horizontalStackWeatherDetails.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingSmall),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.hourlyCollectionHeight),

            dailyTableView.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            dailyTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dailyTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dailyTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dailyTableView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.dailyTableHeight)
        ])
    }
}


