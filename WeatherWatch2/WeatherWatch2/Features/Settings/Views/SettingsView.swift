//
//  SettingsView.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 12.09.2024.
//

import UIKit

/// Основное представление для отображения настроек
class SettingsView: UIView {
    // MARK: - UI Elements

    /// Метка для выбора температуры
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.temperatureLabel
        return label
    }()

    /// Сегментированный контрол для выбора единиц измерения температуры
    lazy var temperatureSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Constants.Strings.celsiusUnit, Constants.Strings.fahrenheitUnit])
        control.selectedSegmentIndex = 0
        return control
    }()

    /// Метка для выбора скорости ветра
    private lazy var windSpeedLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.windSpeedLabel
        return label
    }()

    /// Сегментированный контрол для выбора единиц измерения скорости ветра
    lazy var windSpeedSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Constants.Strings.meterPerSecondUnit, Constants.Strings.kmPerHourUnit, Constants.Strings.mphSettingsUnit, Constants.Strings.knotsSettingsUnit])
        control.selectedSegmentIndex = 0
        return control
    }()

    /// Метка для выбора единиц измерения давления
    private lazy var pressureLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.pressureLabel
        return label
    }()

    /// Сегментированный контрол для выбора единиц измерения давления
    lazy var pressureSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Constants.Strings.hPaUnit, Constants.Strings.mmHgUnit, Constants.Strings.mbarUnit, Constants.Strings.inHgSettingsUnit])
        control.selectedSegmentIndex = 0
        return control
    }()

    /// Метка для выбора темы
    private lazy var themeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Strings.themeLabel
        return label
    }()

    /// Сегментированный контрол для выбора темы оформления
    lazy var themeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [Constants.Strings.lightTheme, Constants.Strings.darkTheme])
        control.selectedSegmentIndex = 0
        return control
    }()

    /// Вертикальный стек для упорядочивания элементов интерфейса
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.Dimensions.paddingMedium
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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

    /// Настраивает и добавляет элементы интерфейса на экран
    private func setupSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(temperatureLabel)
        stackView.addArrangedSubview(temperatureSegmentedControl)
        stackView.addArrangedSubview(windSpeedLabel)
        stackView.addArrangedSubview(windSpeedSegmentedControl)
        stackView.addArrangedSubview(pressureLabel)
        stackView.addArrangedSubview(pressureSegmentedControl)
        stackView.addArrangedSubview(themeLabel)
        stackView.addArrangedSubview(themeSegmentedControl)
    }

    /// Устанавливает ограничения для размещения элементов интерфейса
    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

//#Preview("SettingsView") {
//    SettingsView()
//}
