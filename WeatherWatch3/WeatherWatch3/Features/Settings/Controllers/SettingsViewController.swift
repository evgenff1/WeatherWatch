//
//  SettingsViewController.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 12.09.2024.
//

import UIKit

/// Контроллер для управления настройками приложения
class SettingsViewController: UIViewController {
    // MARK: - Properties

    /// Основное представление настроек
    private let settingsView = SettingsView()

    // MARK: - Lifecycle

    /// Настраивает основное представление контроллера
    override func loadView() {
        self.view = settingsView
    }

    /// Метод вызывается после загрузки представления
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.Strings.settingsTitle
        view.backgroundColor = Constants.Colors.background

        // Загрузка сохраненных настроек
        loadSettings()

        settingsView.temperatureSegmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        settingsView.windSpeedSegmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        settingsView.pressureSegmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
        settingsView.themeSegmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
    }

    // MARK: - Actions

    /// Обработчик изменения сегмента
    /// - Parameter sender: Элемент управления сегментом
    @objc private func didChangeSegment(_ sender: UISegmentedControl) {
        saveSettings()
    }

    // MARK: - Helper Methods

    /// Загружает сохраненные настройки и обновляет интерфейс
    private func loadSettings() {
        settingsView.temperatureSegmentedControl.selectedSegmentIndex = SettingsManager.shared.temperatureUnit
        settingsView.windSpeedSegmentedControl.selectedSegmentIndex = SettingsManager.shared.windSpeedUnit
        settingsView.pressureSegmentedControl.selectedSegmentIndex = SettingsManager.shared.pressureUnit
        settingsView.themeSegmentedControl.selectedSegmentIndex = SettingsManager.shared.theme
    }

    /// Сохраняет текущие настройки и отправляет уведомление о смене настроек
    private func saveSettings() {
        SettingsManager.shared.temperatureUnit = settingsView.temperatureSegmentedControl.selectedSegmentIndex
        SettingsManager.shared.windSpeedUnit = settingsView.windSpeedSegmentedControl.selectedSegmentIndex
        SettingsManager.shared.pressureUnit = settingsView.pressureSegmentedControl.selectedSegmentIndex
        SettingsManager.shared.theme = settingsView.themeSegmentedControl.selectedSegmentIndex

        NotificationCenter.default.post(name: Constants.Notifications.settingsChanged, object: nil)
    }
}

