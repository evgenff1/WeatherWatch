//
//  SceneDelegate.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Properties
    
    /// Окно приложения
    var window: UIWindow?
    
    // MARK: - UIScene Lifecycle
    
    /// Функция вызывается при подключении сцены, настройка сцены приложения
    /// - Parameters:
    ///   - scene: сцена приложения
    ///   - session: сессия сцены
    ///   - connectionOptions: опции подключения
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let rootVC = SplashViewController()
        window.rootViewController = rootVC
        self.window = window
        window.makeKeyAndVisible()
        
        // Применение темы сразу при запуске
        SettingsManager.shared.applyTheme()
    }
    
}

