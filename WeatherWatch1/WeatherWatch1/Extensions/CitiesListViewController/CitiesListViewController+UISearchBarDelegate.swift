//
//  CitiesListViewController+UISearchBarDelegate.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 05.09.2024.
//

import UIKit

extension CitiesListViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBarDelegate Methods
    
    /// Обработка изменения текста в поисковой строке.
    /// - Parameters:
    ///   - searchBar: Поисковая строка.
    ///   - searchText: Новый текст для поиска.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Если строка поиска пустая, очищаем результаты поиска
            self.searchResults = []
            self.citiesListView.tableView.reloadData()
            return
        }
        
        NetworkManager.shared.searchCity(query: searchText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    self?.searchResults = results
                    self?.citiesListView.tableView.reloadData()
                    
                case .failure(let error):
                    print("Ошибка при поиске города: \(error)")
                    self?.searchResults = [] // Очистка результатов при ошибке
                    self?.citiesListView.tableView.reloadData()
                }
            }
        }
    }
    
    /// Обработка начала редактирования текста.
    /// - Parameter searchBar: Поисковая строка.
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Проверить, находится ли таблица в режиме редактирования, и если да, выйти из него
        if citiesListView.tableView.isEditing {
            citiesListView.tableView.setEditing(false, animated: true)
            citiesListView.editButton.setTitle(Constants.Strings.editButtonTitle, for: .normal)
        }
        // Скрываем заголовок
        citiesListView.headerLabel.isHidden = true
        searchBar.showsCancelButton = true
        citiesListView.editButton.isHidden = true
        
        citiesListView.tableView.reloadData()
        
        UIView.animate(withDuration: Constants.Animation.durationShort) {
            // Поднимаем строку поиска и таблицу
            self.citiesListView.searchBar.frame.origin.y = self.view.safeAreaInsets.top
            self.citiesListView.tableView.frame.origin.y = self.citiesListView.searchBar.frame.maxY
        }
    }
    
    /// Обработка нажатия кнопки отмены.
    /// - Parameter searchBar: Поисковая строка.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Возвращаем кнопку редактирования и заголовок
        searchBar.showsCancelButton = false
        citiesListView.editButton.isHidden = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        // Очищаем результаты поиска и возвращаем список городов
        searchResults = []
        citiesListView.tableView.reloadData()
        
        // Возвращаем заголовок и положение поиска
        citiesListView.headerLabel.isHidden = false
        UIView.animate(withDuration: Constants.Animation.durationShort) {
            self.citiesListView.searchBar.frame.origin.y = self.citiesListView.headerLabel.frame.maxY + Constants.Dimensions.paddingSmall
            self.citiesListView.tableView.frame.origin.y = self.citiesListView.searchBar.frame.maxY + Constants.Dimensions.paddingSmall
        }
    }
    
}
