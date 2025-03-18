//
//  NetworkMonitor.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 01.09.2024.
//

import Network
import Alamofire

/// `NetworkMonitor` контролирует текущее состояние подключения к интернету для приложения.
/// Этот класс реализован как синглтон для следующих целей:
/// - Центральный контроль состояния сети: синглтон обеспечивает единый источник информации
///   о состоянии сети, доступный во всем приложении.
/// - Экономия ресурсов: использование единственного экземпляра `NWPathMonitor` предотвращает
///   создание множества объектов мониторинга сети, что упрощает управление.
/// - Автоматическое обновление состояния: `NetworkMonitor` поддерживает актуальное состояние
///   подключения, что позволяет приложению быстро реагировать на изменения подключения к интернету.
final class NetworkMonitor {
    
    // MARK: - Singleton Instance
    
    /// Статическое свойство, создающее и предоставляющее единый экземпляр `NetworkMonitor`.
    static let shared = NetworkMonitor()
    
    // MARK: - Properties
    
    /// Менеджер доступности сети из Alamofire
    private let reachabilityManager = NetworkReachabilityManager()
    
    /// Свойство, указывающее, есть ли подключение к интернету.
    /// Обновляется при изменениях в состоянии сети.
    private(set) var isConnected: Bool = true
    
    // MARK: - Initialization
    
    /// Приватный инициализатор, который запускает отслеживание состояния сети.
     private init() {
         startMonitoring()
     }
    
    // MARK: - Methods
    
    /// Запускает мониторинг состояния сети
    private func startMonitoring() {
        reachabilityManager?.startListening { [weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.isConnected = false
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                self?.isConnected = true
            }
        }
    }
}

