//
//  SplashView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 30.08.2024.
//

import UIKit

/// Представление экрана загрузки, отображающее логотип приложения и название.
class SplashView: UIView {
    
    // MARK: - Properties
        
    /// Изображение логотипа приложения.
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Constants.Images.appIcon
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Текст "Загрузка", отображающий процесс загрузки.
    private lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.loading
        label.textAlignment = .center
        label.font = Constants.Fonts.loadingLabelDescription
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Название приложения, отображаемое в нижней части экрана.
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.appName
        label.textAlignment = .center
        label.font = Constants.Fonts.appName
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
        
    /// Добавление подвидов на экран.
    private func setupSubviews() {
        addSubview(logoImageView)
        addSubview(loadingLabel)
        addSubview(appNameLabel)
    }
    
    /// Настройка макета с использованием Auto Layout.
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Логотип по центру
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Constants.Dimensions.paddingLarge),
            logoImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.logoWidth),
            logoImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.logoHeight),
            
            // Текст "Fetching the weather..." под логотипом
            loadingLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: Constants.Dimensions.paddingLarge),
            loadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            loadingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            
            // Название приложения снизу
            appNameLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Dimensions.paddingLarge),
            appNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            appNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Dimensions.paddingMedium)
        ])
    }
}
