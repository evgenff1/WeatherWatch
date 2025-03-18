//
//  CitiesListViewController+TableView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 04.09.2024.
//

import UIKit

// MARK: - UITableViewDelegate

extension CitiesListViewController: UITableViewDelegate {
    
    // MARK: - Row Selection
    
    /// Обработка выбора строки в таблице.
    /// - Parameter tableView: Таблица с городами.
    /// - Parameter indexPath: Индекс выбранной строки.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Проверяем, в режиме поиска ли мы
        if citiesListView.searchBar.text?.isEmpty == false {
            let selectedCity = searchResults[indexPath.row]
            
            if RealmManager.shared.findCityByCoordinates(selectedCity.latitude, selectedCity.longitude) != nil {
                // Если город уже есть, показываем сообщение и прекращаем выполнение
                showAlert(cityName: LocalizationHelper.localizedCityName(cityResult: selectedCity))
                return
            } else {
                // Если город не найден, добавляем его в базу данных
                addCityToDatabase(cityName: selectedCity.name,
                                  latitude: selectedCity.latitude,
                                  longitude: selectedCity.longitude,
                                  localNameEn: selectedCity.localNameEn,
                                  localNameRu: selectedCity.localNameRu)
                // Переходим к новому городу
                let newCityIndex = cities.count - 1
                delegate?.didSelectCity(at: newCityIndex)
            }
            
        } else {
            // Выбираем город из уже существующего списка
            let selectedCityIndex = indexPath.row
            delegate?.didSelectCity(at: selectedCityIndex)
        }
        
        // Закрываем поисковую панель
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource

extension CitiesListViewController: UITableViewDataSource {
    
    // MARK: - Data Source Methods
    
    /// Количество строк в разделе таблицы.
    /// - Parameter tableView: Таблица с городами.
    /// - Parameter section: Раздел таблицы.
    /// - Returns: Количество строк в разделе.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Если в поисковой строке есть текст, отображаем результаты поиска
        if !(citiesListView.searchBar.text?.isEmpty ?? true) {
            return searchResults.count
        }
        
        // Если пользователь не вводит текст в строку поиска, возвращаем количество городов
        return citiesListView.searchBar.isFirstResponder ? 0 : cities.count
    }
    
    /// Настройка ячейки таблицы.
    /// - Parameter tableView: Таблица с городами.
    /// - Parameter indexPath: Индекс строки таблицы.
    /// - Returns: Настроенная ячейка таблицы.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CitiesListView.reuseIdentifier, for: indexPath)
        
        if citiesListView.searchBar.text?.isEmpty == false {
            let cityResult = searchResults[indexPath.row]
            cell.textLabel?.text = "\(LocalizationHelper.localizedCityName(cityResult: cityResult)), \(cityResult.state), \(cityResult.country)"
        } else {
            let city = cities[indexPath.row]
            if city.isCurrentLocation {
                cell.textLabel?.text = "\(LocalizationHelper.localizedCityName(cityObject: city))" + Constants.Strings.currentLocationSuffix
            } else {
                cell.textLabel?.text = LocalizationHelper.localizedCityName(cityObject: city)
            }
        }
        return cell
    }
    
}

// MARK: - UITableView Editing

extension CitiesListViewController {
    
    // MARK: - Row Editing
    
    /// Позволяет редактировать таблицу.
    /// - Parameters:
    ///   - tableView: Таблица с городами.
    ///   - indexPath: Индекс строки таблицы.
    /// - Returns: Boolean, разрешает ли редактирование строки.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Запрещаем перемещение первого города (если он текущий)
        if indexPath.row == 0, cities.count != 0, cities[indexPath.row].isCurrentLocation {
            return false
        }
        return true
    }
    
    /// Настройка целевого индекса перемещения.
    /// - Parameters:
    ///   - tableView: Таблица с городами.
    ///   - sourceIndexPath: Исходный индекс строки.
    ///   - proposedDestinationIndexPath: Предложенный индекс строки.
    /// - Returns: Окончательный индекс строки для перемещения.
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // Запрещаем перемещение на место первого города
        if proposedDestinationIndexPath.row == 0, cities.count != 0, cities[0].isCurrentLocation {
            return sourceIndexPath // возвращаем исходную позицию, если попытка перемещения на первую строку
        }
        return proposedDestinationIndexPath
    }
    
    /// Определяет возможность редактирования строки.
    /// - Parameters:
    ///   - tableView: Таблица с городами.
    ///   - indexPath: Индекс строки таблицы.
    /// - Returns: true, если строку можно редактировать, иначе false.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Если это первый город с признаком isCurrentLocation, запрещаем редактирование
        if indexPath.row == 0, cities.count != 0, cities[indexPath.row].isCurrentLocation {
            return false
        }
        return true
    }
    
    /// Настройка целевого индекса перемещения.
    /// - Parameters:
    ///   - tableView: Таблица с городами.
    ///   - sourceIndexPath: Исходный индекс строки.
    ///   - proposedDestinationIndexPath: Предложенный индекс строки.
    /// - Returns: Окончательный индекс строки для перемещения.
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCity = cities.remove(at: sourceIndexPath.row)
        cities.insert(movedCity, at: destinationIndexPath.row)
        
        // Обновляем порядок городов в базе данных
        RealmManager.shared.updateCityOrder(cities)
        
        // Передача обновленного списка городов через делегат
        delegate?.didUpdateCities(cities)
        
    }
    
    /// Удаление строки.
    /// - Parameters:
    ///   - tableView: Таблица с городами.
    ///   - editingStyle: Стиль редактирования.
    ///   - indexPath: Индекс строки.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cityToDelete = cities[indexPath.row]
            cities.remove(at: indexPath.row)
            
            // Удаляем город из базы данных
            RealmManager.shared.deleteCity(cityToDelete)
            
            // Обновляем порядок городов после удаления
            RealmManager.shared.updateCityOrder(cities)
            
            // Обновляем интерфейс
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Передача обновленного списка городов через делегат
            delegate?.didUpdateCities(cities)
        }
    }
}
