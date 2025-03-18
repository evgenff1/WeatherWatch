//
//  WeatherViewController.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

/// Контроллер для отображения информации о погоде в выбранном городе
class WeatherViewController: UIViewController {
    
    // MARK: - Properties
    
    /// ViewModel для получения данных о погоде
    var weatherViewModel: WeatherViewModel!
    
    /// Представление для отображения информации о погоде
    private var weatherView: WeatherView!
    
    /// Контроллер для обновления при pull-to-refresh
    private let refreshControl = UIRefreshControl()
    
    /// Делегат для связи с CitiesListViewController
    weak var delegate: CitiesListViewControllerDelegate?
    
    /// Делегат для управления WeatherViewController
    weak var cacheDelegate: WeatherViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.background
        
        weatherView = WeatherView(frame: view.bounds)
        view.addSubview(weatherView)
        
        setupDelegates()
        
        // Добавляем refreshControl к UIScrollView
        weatherView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
        
        weatherViewModel.updateView = { [weak self] in
            self?.updateUI()
            self?.refreshControl.endRefreshing()
        }
        
        // Подписка на уведомления о возвращении приложения в активное состояние
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        // Подписываемся на уведомления об изменении настроек
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSettings),
                                               name: Constants.Notifications.settingsChanged,
                                               object: nil)
        
        updateUI()
    }
    
    // MARK: - Private Methods
    
    /// Обновляет интерфейс при изменении настроек
    @objc private func updateSettings() {
        updateUI()
    }
    
    /// Метод для обновления данных при pull-to-refresh
    @objc private func refreshWeatherData() {
        // Проверяем подключение к интернету перед обновлением данных
        if NetworkMonitor.shared.isConnected {
            Task { @MainActor in
                await weatherViewModel.fetchWeather()
                refreshControl.endRefreshing()
            }
        } else {
            Task { @MainActor in
                self.showNoInternetConnectionMessage()
                refreshControl.endRefreshing()
            }
        }
    }
    
    /// Проверяет подключение к интернету перед обновлением данных
    func checkInternetConnectionBeforeFetching() {
        if NetworkMonitor.shared.isConnected {
            Task { @MainActor in
                await weatherViewModel.fetchWeather()
            }
        } else {
            // Отложенный вызов showNoInternetConnectionMessage
            Task { @MainActor in
                self.showNoInternetConnectionMessage()
            }
        }
    }
    
    /// Обработчик события при переходе приложения в активное состояние
    @objc private func appDidBecomeActive() {
        guard isViewLoaded, view.window != nil else { return }
        
        if !refreshControl.isRefreshing {
            weatherView.scrollView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()
            refreshWeatherData()
        }
    }
    
    /// Отображает сообщение об отсутствии подключения к интернету
    private func showNoInternetConnectionMessage() {
        weatherView.descriptionLabel.text = Constants.Strings.noInternetTitle
        weatherView.feelsLikeLabel.text = Constants.Strings.noInternetMessage
    }
    
    /// Устанавливает делегаты для collectionView и tableView
    private func setupDelegates() {
        weatherView.hourlyCollectionView.dataSource = self
        weatherView.hourlyCollectionView.delegate = self
        
        weatherView.dailyTableView.dataSource = self
        weatherView.dailyTableView.delegate = self
    }
    
    /// Обновляет интерфейс с использованием данных из ViewModel
    private func updateUI() {
        weatherView.cityLabel.text = weatherViewModel.cityName
        weatherView.temperatureLabel.text = weatherViewModel.temperature
        
        weatherView.descriptionLabel.text = weatherViewModel.description
        weatherView.feelsLikeLabel.text = weatherViewModel.feelsLike
        
        weatherView.sunriseLabel.text = weatherViewModel.sunrise
        weatherView.sunsetLabel.text = weatherViewModel.sunset
        
        weatherView.windLabel.text = weatherViewModel.windSpeed
        weatherView.humidityLabel.text = weatherViewModel.humidity
        weatherView.pressureLabel.text = weatherViewModel.pressure
        
        Task { @MainActor in
            if let icon = weatherViewModel.forecastResponse?.list.first?.weather.first?.icon {
                self.weatherView.weatherIconImageView.image = await IconCacheManager.shared.getIcon(for: icon)
            }
        }
        
        weatherView.hourlyCollectionView.reloadData()
        weatherView.dailyTableView.reloadData()
    }
    
    // MARK: - Deinitialization
    
    /// Отписываемся от уведомлений при деинициализации
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: Constants.Notifications.settingsChanged,
                                                  object: nil)
    }
}
