//
//  CitiesListViewController.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 04.09.2024.
//

import UIKit

// MARK: - CitiesListViewController
class CitiesListViewController: UIViewController {

    // MARK: - Properties
    
    /// Делегат для передачи данных о городах
    weak var delegate: CitiesListViewControllerDelegate?
    
    /// Представление списка городов
    let citiesListView = CitiesListView()
    
    /// Массив сохраненных городов
    var cities: [CityObject] = []
    
    /// Массив результатов поиска городов
    var searchResults: [CitySearchResult] = []
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = citiesListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.background
        cities = RealmManager.shared.getCities() ?? []
        
        setupDelegates()
        citiesListView.tableView.reloadData()
        
        citiesListView.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    // MARK: - UI Methods
    
    /// Обработчик нажатия кнопки "Редактировать"
    @objc private func editButtonTapped() {
        citiesListView.tableView.setEditing(!citiesListView.tableView.isEditing, animated: true)
        
        let newTitle = citiesListView.tableView.isEditing ? Constants.Strings.doneButtonTitle : Constants.Strings.editButtonTitle
        citiesListView.editButton.setTitle(newTitle, for: .normal)
    }

    // MARK: - Setup Methods
    
    /// Настройка делегатов для компонентов интерфейса
    private func setupDelegates() {
        citiesListView.tableView.dataSource = self
        citiesListView.tableView.delegate = self
        citiesListView.searchBar.delegate = self
    }
    
    // MARK: - Database Methods
    
    /// Добавляет новый город в базу данных
    /// - Parameters:
    ///   - cityName: Название города
    ///   - latitude: Широта города
    ///   - longitude: Долгота города
    ///   - localNameEn: Название города на английском языке
    ///   - localNameRu: Название города на русском языке
    func addCityToDatabase(cityName: String, latitude: Double, longitude: Double, localNameEn: String, localNameRu: String) {
        let newCity = CityObject(name: cityName, latitude: latitude, longitude: longitude, localNameEn: localNameEn, localNameRu: localNameRu)
        newCity.order = cities.count // Устанавливаем порядковый номер
        
        if cities.isEmpty {
            RealmManager.shared.updateCurrentLocationFlag(for: newCity)
        }
        
        RealmManager.shared.addCity(newCity)
        cities = RealmManager.shared.getCities() ?? []
        citiesListView.tableView.reloadData()
        
        delegate?.didUpdateCities(cities)
        
        let newCityIndex = cities.count - 1
        delegate?.didSelectCity(at: newCityIndex)
    }

    /// Показывает сообщение об ошибке при добавлении города
    /// - Parameter cityName: Название города, которое уже существует
    func showAlert(cityName: String) {
        let alert = UIAlertController(
            title: Constants.Strings.cityAlreadyExistsTitle,
            message: String(format: NSLocalizedString(Constants.Strings.cityAlreadyExistsMessage, comment: ""), cityName),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.Strings.cityListOK, style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
}


