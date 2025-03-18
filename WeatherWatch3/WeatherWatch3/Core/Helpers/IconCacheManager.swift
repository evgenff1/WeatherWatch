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
    ///  - Parameter iconName: Имя иконки, используемое как ключ для кэша и идентификатор загрузки.
    ///  - Returns: UIImage?, загруженную из сети или кэша. В случае ошибки возвращает nil.
    func getIcon(for iconName: String) async -> UIImage? {
        let cacheKey = NSString(string: iconName)
        
        // Если иконка есть в кэше, возвращаем её сразу
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Формируем URL для загрузки иконки
        guard let url = iconURL(for: iconName) else {
            return nil
        }
        
        do {
            // Используем await для асинхронной загрузки данных
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                cache.setObject(image, forKey: cacheKey)
                return image
            }
        } catch {
            print("Ошибка загрузки иконки: \(error)")
        }
        return nil
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


