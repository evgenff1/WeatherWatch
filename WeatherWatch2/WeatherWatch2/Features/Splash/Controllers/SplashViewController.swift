//
//  SplashViewController.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 30.08.2024.
//

import UIKit

/// Контроллер начального экрана с логикой перехода к основному экрану.
class SplashViewController: UIViewController {

    // MARK: - Properties
        
    /// Основное представление для экрана Splash.
    private let splashView = SplashView()
    
    /// Модель данных для погоды, используется для получения данных о текущей погоде.
    private var weatherViewModel: WeatherViewModel?
    
    /// Последний выбранный город.
    private var lastCity: CityObject?

    // MARK: - Lifecycle Methods
        
    /// Загрузка основного представления.
    override func loadView() {
        self.view = splashView
    }
    
    /// Действия после загрузки представления.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.Colors.primaryAccent
        
        initializeViewModel()
    }
        
    // MARK: - ViewModel Initialization
        
    /// Инициализация модели данных погоды.
    private func initializeViewModel() {
        
        // Проверяем наличие интернет-соединения
         if NetworkMonitor.shared.isConnected {
             // Получаем последний выбранный город
             lastCity = RealmManager.shared.getLastSelectedCity()
             
             // Если выбранный город есть, используем его; иначе используем первый город из БД
             if let city = lastCity ?? RealmManager.shared.getCities()?.first {
                 weatherViewModel = WeatherViewModel(cityObject: city)
             } else {
                 weatherViewModel = nil
             }
             
             // Если город известен, загружаем погоду
             if let viewModel = weatherViewModel {
                 viewModel.fetchWeather()
                 viewModel.updateView = { [weak self] in
                     self?.navigateToMainScreen()
                     // Для обновления широты и долготы после загрузки первого города
                     DispatchQueue.main.async {
                         DataUpdater.shared.startUpdatingCities()
                     }
                 }
             } else {
                 // Если город не установлен, сразу переходим на главный экран
                 navigateToMainScreen()
             }
         } else {
             // При отсутствии интернета переходим сразу на главный экран
             navigateToMainScreen()
         }
    }
    
    // MARK: - Navigation
        
    /// Переход к основному экрану приложения.
    private func navigateToMainScreen() {
        let citiesPageVC = CitiesPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

        // Инициализируем citiesViewModel перед тем, как устанавливать индекс
        citiesPageVC.citiesViewModel = CitiesViewModel()

        // Получаем последний выбранный город
        if let lastCity = lastCity {
            if let cityIndex = citiesPageVC.citiesViewModel.cities.firstIndex(where: { $0.id == lastCity.id }) {
                // Устанавливаем начальный индекс на сохраненный город
                citiesPageVC.citiesViewModel.setCurrentCityIndex(to: cityIndex)
                citiesPageVC.citiesPageView.pageControl.currentPage = citiesPageVC.citiesViewModel.currentIndex
            }
        } else {
            // Если сохраненного города нет, устанавливаем индекс на первый город
            citiesPageVC.citiesViewModel.setCurrentCityIndex(to: 0)
            citiesPageVC.citiesPageView.pageControl.currentPage = citiesPageVC.citiesViewModel.currentIndex
        }

        citiesPageVC.weatherViewModel = weatherViewModel
        
        // Добавляем CitiesPageViewController в UINavigationController
        let navigationController = UINavigationController(rootViewController: citiesPageVC)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navigationController
        }
    }

}

