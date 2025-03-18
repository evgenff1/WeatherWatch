//
//  CitiesListView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 04.09.2024.
//

import UIKit

// MARK: - CitiesListView
class CitiesListView: UIView {
    
    // MARK: - Properties
    
    /// Заголовок с надписью города
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.weatherLabelTitle
        label.font = Constants.Fonts.cityTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Строка поиска для ввода города
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Constants.Strings.searchPlaceholder
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = Constants.Colors.background
        return searchBar
    }()
    
    /// Кнопка редактирования списка городов
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Strings.editButtonTitle, for: .normal)
        button.titleLabel?.font = Constants.Fonts.loadingLabelDescription
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Таблица для отображения списка городов
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: CitiesListView.reuseIdentifier)
        return table
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// Метод добавления подвидов в представление
    private func setupSubviews() {
        addSubview(headerLabel)
        addSubview(searchBar)
        addSubview(editButton)
        addSubview(tableView)
    }
    
    /// Метод настройки ограничений для компонентов интерфейса
    private func setupLayout() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.Dimensions.paddingMedium),
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Dimensions.paddingSmall),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Dimensions.paddingSmall),
            
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            editButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.Dimensions.paddingMedium),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
