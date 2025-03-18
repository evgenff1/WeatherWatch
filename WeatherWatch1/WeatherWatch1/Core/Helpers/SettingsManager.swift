//
//  SettingsManager.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 12.09.2024.
//

import UIKit

/// `SettingsManager` - это класс, реализованный как синглтон, который отвечает за управление настройками пользователя в приложении.
///
/// Использование синглтона для `SettingsManager` позволяет создать и использовать единый экземпляр этого класса во всем приложении.
/// Такой подход обеспечивает доступ к пользовательским настройкам из любого места в коде и гарантирует:
/// - Централизованное управление настройками: все изменения настроек происходят через единую точку доступа, что повышает контроль.
/// - Минимизацию использования ресурсов: создание единственного экземпляра `SettingsManager` исключает ненужное дублирование.
/// - Удобство хранения в `UserDefaults`: все настройки сохраняются в `UserDefaults`, что позволяет сохранять их между запусками приложения.
///
/// `SettingsManager` содержит настройки, такие как единицы измерения для температуры, скорости ветра и давления, а также темы оформления приложения.
final class SettingsManager {
    
    // MARK: - Singleton Instance
    
    /// Статический экземпляр `SettingsManager` для централизованного управления настройками пользователя.
    static let shared = SettingsManager()

    // MARK: - UserDefaults Keys
    
    /// Ключ для сохранения единицы измерения температуры.
    private let temperatureUnitKey = Constants.UserDefaultsKeys.temperatureUnit
    
    /// Ключ для сохранения единицы измерения скорости ветра.
    private let windSpeedUnitKey = Constants.UserDefaultsKeys.windSpeedUnit
    
    /// Ключ для сохранения единицы измерения давления.
    private let pressureUnitKey = Constants.UserDefaultsKeys.pressureUnit
    
    /// Ключ для сохранения темы оформления.
    private let themeKey = Constants.UserDefaultsKeys.theme
    
    // MARK: - Initialization
    
    /// Приватный инициализатор, предотвращающий создание других экземпляров `SettingsManager`.
    private init() {}

    // MARK: - Temperature Unit
    
    /// Единица измерения температуры.
    /// Получает значение из `UserDefaults`, а при изменении сохраняет новое значение в `UserDefaults`.
    var temperatureUnit: Int {
        get {
            return UserDefaults.standard.integer(forKey: temperatureUnitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: temperatureUnitKey)
        }
    }

    // MARK: - Wind Speed Unit
    
    /// Единица измерения скорости ветра.
    /// Получает значение из `UserDefaults`, а при изменении сохраняет новое значение в `UserDefaults`.
    var windSpeedUnit: Int {
        get {
            return UserDefaults.standard.integer(forKey: windSpeedUnitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: windSpeedUnitKey)
        }
    }

    // MARK: - Pressure Unit
    
    /// Единица измерения давления.
    /// Получает значение из `UserDefaults`, а при изменении сохраняет новое значение в `UserDefaults`.
    var pressureUnit: Int {
        get {
            return UserDefaults.standard.integer(forKey: pressureUnitKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: pressureUnitKey)
        }
    }

    // MARK: - Theme
    
    /// Текущая тема приложения.
    /// При изменении темы применяется функция `applyTheme()`.
    var theme: Int {
        get {
            return UserDefaults.standard.integer(forKey: themeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: themeKey)
            applyTheme()
        }
    }
    
    // MARK: - Apply Theme
    
    /// Применяет выбранную тему к пользовательскому интерфейсу.
    /// Зависит от выбранной темы: светлая или темная.
    func applyTheme() {
        let selectedTheme = theme == 0 ? UIUserInterfaceStyle.light : .dark
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = selectedTheme
            }
        }
    }
}



