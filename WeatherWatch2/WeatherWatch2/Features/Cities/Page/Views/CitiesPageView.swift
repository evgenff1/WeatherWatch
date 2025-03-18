//
//  CitiesPageView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

// MARK: - CitiesPageView
class CitiesPageView: UIView {
    
    // MARK: - Properties
    
    /// Индикатор текущей страницы, отображает количество страниц
    lazy var pageControl: UIPageControl = {
        let page = UIPageControl()
        page.currentPageIndicatorTintColor = Constants.Colors.primaryText
        page.pageIndicatorTintColor = Constants.Colors.secondaryText
        page.translatesAutoresizingMaskIntoConstraints = false
        return page
    }()
    
    /// Горизонтальная линия, разделяющая элементы интерфейса
    private lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = Constants.Colors.separator
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    /// Кнопка меню для открытия бокового меню
    lazy var menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Constants.Images.menuIcon, for: .normal)
        button.tintColor = Constants.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Кнопка для перехода к настройкам
    lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Constants.Images.settingsIcon, for: .normal)
        button.tintColor = Constants.Colors.primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        addSubview(lineView)
        addSubview(pageControl)
        addSubview(menuButton)
        addSubview(settingsButton)
    }
    
    /// Метод настройки ограничений для компонентов интерфейса
    private func setupLayout() {
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.lineHeight),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -Constants.Dimensions.paddingSmall),

            pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: Constants.Dimensions.pageControlHeight),

            menuButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            menuButton.bottomAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            menuButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.buttonSize),
            menuButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.buttonSize),

            settingsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            settingsButton.bottomAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: Constants.Dimensions.paddingSmall),
            settingsButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.buttonSize),
            settingsButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.buttonSize)
        ])
    }
}


