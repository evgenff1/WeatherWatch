//
//  CitiesPageViewController.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

// MARK: - ViewController Source Enumeration

/// Перечисление источников ViewController.
enum ViewControllerSource {
    case splash
    case citiesPage
}

// MARK: - CitiesPageViewController Class

/// Контроллер страницы городов, управляет отображением погодной информации по выбранным городам.
class CitiesPageViewController: UIPageViewController {
    
    // MARK: - Properties
    
    /// Указывает, был ли контроллер отображен впервые.
    private var didFirstAppear = false
    
    /// ViewModel для отображения погодной информации.
    var weatherViewModel: WeatherViewModel?
    
    /// Основное представление страницы городов.
    let citiesPageView: CitiesPageView = {
        let view = CitiesPageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// ViewModel для управления данными о городах.
    var citiesViewModel: CitiesViewModel!
    
    /// Кэш для хранения экземпляров `WeatherViewController` по id города.
    let weatherViewControllersCache = NSCache<NSString, WeatherViewController>()
    
    // MARK: - Lifecycle Methods
    
    /// Метод вызывается после загрузки представления.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.background
        dataSource = self
        delegate = self
        
        if citiesViewModel == nil {
            citiesViewModel = CitiesViewModel()
        }
        
        if citiesViewModel.cities.isEmpty {
            requestLocationPermissionAndHandleEvents()
        } else {
            setupFirstCity()
        }
        
        setupCitiesPageView()
        setupPageControl()
        setupMenuButton()
        setupSettingsButton()
        
        // Подписка на уведомление о том, что приложение стало активным
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    /// Метод вызывается при появлении представления на экране.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didFirstAppear {
            didFirstAppear = true
            appDidBecomeActive()
        }
    }
    
    // MARK: - Event Handling Methods
    
    /// Обработчик события, когда приложение становится активным.
    @objc private func appDidBecomeActive() {
        guard isViewLoaded, view.window != nil else { return }
        
        if !citiesViewModel.cities.isEmpty {
            LocationManager.shared.requestLocation()
            
            LocationManager.shared.onLocationUpdate = { [weak self] newCity in
                guard let self = self else { return }
                
                let updatedCities = RealmManager.shared.getCities()
                self.citiesViewModel.cities = updatedCities ?? []
                
                let cityId = newCity.id.stringValue
                self.weatherViewControllersCache.removeObject(forKey: cityId as NSString)
                
                let currentIndex = self.citiesViewModel.currentIndex
                self.didSelectCity(at: currentIndex)
            }
            
            LocationManager.shared.onLocationError = { error in
                print("Location error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Запрашивает разрешение на доступ к местоположению и обрабатывает события обновления локации.
    private func requestLocationPermissionAndHandleEvents() {
        LocationManager.shared.requestLocation()
        
        LocationManager.shared.onLocationUpdate = { [weak self] newCity in
            guard let self = self else { return }
            self.citiesViewModel.cities = RealmManager.shared.getCities() ?? []
            self.weatherViewModel = WeatherViewModel(cityObject: newCity)
            
            if let weatherVC = self.createWeatherViewController(for: newCity, from: .splash) {
                self.setViewControllers([weatherVC], direction: .forward, animated: true, completion: nil)
            }
            self.citiesPageView.pageControl.numberOfPages = self.citiesViewModel.numberOfCities
        }
        
        LocationManager.shared.onLocationError = { [weak self] error in
            guard let self = self else { return }
            print("Location error: \(error.localizedDescription)")
            self.openCitiesList()
        }
    }
    
    // MARK: - Setup Methods
    
    /// Настройка отображения первого города.
    private func setupFirstCity() {
        if let firstVC = createWeatherViewController(for: citiesViewModel.currentCity, from: .splash) {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    /// Настройка представления страницы городов.
    private func setupCitiesPageView() {
        view.addSubview(citiesPageView)
        
        NSLayoutConstraint.activate([
            citiesPageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesPageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesPageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            citiesPageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.citiesPageViewHeight)
        ])
    }
    
    /// Настройка кнопки меню.
    private func setupMenuButton() {
        citiesPageView.menuButton.addTarget(self, action: #selector(openCitiesList), for: .touchUpInside)
    }
    
    /// Настройка кнопки настроек.
    private func setupSettingsButton() {
        citiesPageView.settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
    }
    
    /// Настройка PageControl.
    private func setupPageControl() {
        citiesPageView.pageControl.numberOfPages = citiesViewModel.numberOfCities
        citiesPageView.pageControl.currentPage = citiesViewModel.currentIndex
        citiesPageView.pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        
        updatePageControlImages()
    }
    
    // MARK: - Helper Methods
    
    /// Обновление изображений для PageControl.
    func updatePageControlImages() {
        let cities = citiesViewModel.cities
        
        for (index, city) in cities.enumerated() {
            if city.isCurrentLocation {
                let currentLocationImage = Constants.Images.locationIcon
                citiesPageView.pageControl.setIndicatorImage(currentLocationImage, forPage: index)
            } else {
                citiesPageView.pageControl.setIndicatorImage(nil, forPage: index)
            }
        }
    }
    
    // MARK: - Actions
    
    /// Открывает список городов.
    @objc private func openCitiesList() {
        let citiesListVC = CitiesListViewController()
        citiesListVC.delegate = self
        citiesListVC.modalPresentationStyle = .fullScreen
        present(citiesListVC, animated: true, completion: nil)
    }
    
    /// Открывает настройки.
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    /// Обработчик нажатия на PageControl.
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let newIndex = sender.currentPage
        
        let direction: UIPageViewController.NavigationDirection = newIndex > citiesViewModel.currentIndex ? .forward : .reverse
        citiesViewModel.setCurrentCityIndex(to: newIndex)
        
        if let nextVC = createWeatherViewController(for: citiesViewModel.currentCity, from: .citiesPage) {
            setViewControllers([nextVC], direction: direction, animated: true, completion: nil)
        }
        
        updatePageControlImages()
    }
    
    // MARK: - ViewController Creation
    
    /// Создает и возвращает `WeatherViewController` для определенного города.
    /// - Parameters:
    ///   - city: Объект `CityObject`, представляющий город.
    ///   - source: Источник для создания контроллера.
    /// - Returns: Новый `WeatherViewController` или кэшированный экземпляр.
    func createWeatherViewController(for city: CityObject, from source: ViewControllerSource) -> WeatherViewController? {
        let cityId = city.id.stringValue
        
        if let cachedVC = weatherViewControllersCache.object(forKey: cityId as NSString) {
            return cachedVC
        }
        
        let weatherViewController = WeatherViewController()
        
        switch source {
        case .splash:
            if let viewModel = self.weatherViewModel {
                weatherViewController.weatherViewModel = viewModel
            }
        case .citiesPage:
            let newViewModel = WeatherViewModel(cityObject: city)
            weatherViewController.weatherViewModel = newViewModel
            weatherViewController.checkInternetConnectionBeforeFetching()
        }
        
        weatherViewControllersCache.setObject(weatherViewController, forKey: cityId as NSString)
        
        weatherViewController.delegate = self
        weatherViewController.cacheDelegate = self
        
        return weatherViewController
    }
    
    // MARK: - Deinitialization
    
    /// Удаляет наблюдателя перед деинициализацией объекта.
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
}

