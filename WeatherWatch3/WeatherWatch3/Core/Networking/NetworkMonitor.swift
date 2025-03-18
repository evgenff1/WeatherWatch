//
//  NetworkMonitor.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 01.09.2024.
//

import Network

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
    
    /// Приватный экземпляр `NWPathMonitor` для отслеживания состояния сети.
    private let monitor = NWPathMonitor()
    
    /// Асинхронная задача для слежения за изменениями сети.
    private var monitoringTask: Task<Void, Never>?
    
    /// Флаг, показывающий, есть ли подключение к интернету.
    /// По умолчанию считаем, что сеть доступна.
    private(set) var isConnected: Bool = true
    
    // MARK: - Initialization
    
    /// Приватный инициализатор, предотвращающий создание дополнительных экземпляров.
    private init() {}
    
    // MARK: - Network Monitoring
    
    /// Запускает мониторинг состояния сети.
    func startMonitoring() {
        // Останавливаем предыдущий мониторинг, если он уже запущен
        stopMonitoring()
        
        // Запускаем монитор NWPathMonitor на фоне.
        // Это необходимо для того, чтобы async-итератор начал получать события.
        monitor.start(queue: DispatchQueue.global(qos: .background))
        
        // Создаем асинхронную задачу для отслеживания изменений сети
        monitoringTask = Task {
            for await path in monitor {
                // Обновляем флаг подключения
                self.isConnected = path.status == .satisfied
            }
        }
    }
    
    /// Останавливает мониторинг сети.
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }
}

