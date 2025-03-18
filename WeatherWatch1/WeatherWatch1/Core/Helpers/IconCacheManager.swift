//
//  IconCacheManager.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 01.09.2024.
//

import UIKit

/// Класс `IconCacheManager` отвечает за кэширование и загрузку иконок по идентификатору.
/// Он используется для хранения закэшированных изображений иконок, что позволяет
/// оптимизировать производительность приложения, минимизируя количество сетевых запросов.
///
/// Этот класс реализован как синглтон (singleton), так как:
/// - У него есть единый кэш `NSCache`, который должен использоваться во всём приложении.
/// - Это позволяет избежать дублирования кэша и экономит память.
/// - За счёт единственного экземпляра `IconCacheManager` инициализация кэша происходит только один раз,
///   что упрощает управление и уменьшает вероятность ошибок.
///
/// - Note: Для получения иконок используется метод `getIcon(for:completion:)`, который сначала проверяет,
///   находится ли иконка в кэше, и только при её отсутствии загружает её асинхронно из сети.
final class IconCacheManager {
    
    // MARK: - Singleton Instance
    
    /// Единственный экземпляр (синглтон) `IconCacheManager`.
    static let shared = IconCacheManager()

    // MARK: - Properties
    
    /// Кэш для хранения иконок, ключи - имена иконок, значения - `UIImage` объектов.
    private let cache = NSCache<NSString, UIImage>()

    // MARK: - Initializer
    
    /// Приватный инициализатор предотвращает создание дополнительных экземпляров.
    private init() {}
    
    // MARK: - Icon Management
    
    /// Метод получения иконки по её имени. Проверяет наличие иконки в кэше.
    /// Если иконка отсутствует, загружает её асинхронно из сети.
    ///
    /// - Parameters:
    ///   - iconName: Имя иконки, используемое как ключ для кэша и идентификатор загрузки.
    ///   - completion: Замыкание, вызываемое с загруженной `UIImage` или `nil`, если загрузка не удалась.
    func getIcon(for iconName: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: iconName)

        // Проверяем кэш на наличие иконки
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }

        // Формируем URL для загрузки иконки
        guard let url = iconURL(for: iconName) else {
            completion(nil)
            return
        }

        // Загружаем иконку асинхронно
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                // Сохраняем иконку в кэш
                self.cache.setObject(image, forKey: cacheKey)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    /// Формирует URL для иконки по её идентификатору.
    ///
    /// - Parameter iconID: Идентификатор иконки.
    /// - Returns: URL для загрузки иконки или `nil`, если URL не может быть создан.
    func iconURL(for iconID: String) -> URL? {
        var components = URLComponents()
        components.scheme = Constants.API.scheme
        components.host = Constants.API.iconHost
        components.path = Constants.API.iconPath + "\(iconID)" + Constants.API.iconExtension
        
        return components.url
    }
}


