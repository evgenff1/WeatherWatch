//
//  ReusableIdentifier.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

/// Протокол `Reusable` определяет стандартное свойство `reuseIdentifier` для использования в идентификации ячеек UITableView и UICollectionView.
protocol Reusable: AnyObject {
    
    /// Идентификатор повторного использования для ячеек, определяемый на основе имени класса.
    static var reuseIdentifier: String { get }
}

// MARK: - Default Implementation

/// Расширение `Reusable` предоставляет стандартную реализацию свойства `reuseIdentifier`, возвращая имя класса как идентификатор.
extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - Conformance to Reusable

/// Добавление соответствия протоколу `Reusable` для ячеек UITableView, UICollectionView и CitiesListView.
extension UITableViewCell: Reusable {}
extension UICollectionViewCell: Reusable {}
extension CitiesListView: Reusable {}

