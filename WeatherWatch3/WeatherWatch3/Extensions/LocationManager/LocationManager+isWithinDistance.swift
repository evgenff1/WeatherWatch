//
//  LocationManager+isWithinDistance.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 13.09.2024.
//

import CoreLocation

extension LocationManager {
    
    // MARK: - Location Distance
    
    /// Проверка, находится ли расстояние между двумя координатами в пределах заданного максимального расстояния.
    /// - Parameters:
    ///   - lat1: Широта первой координаты.
    ///   - lon1: Долгота первой координаты.
    ///   - lat2: Широта второй координаты.
    ///   - lon2: Долгота второй координаты.
    ///   - maxDistanceInMeters: Максимально допустимое расстояние в метрах.
    /// - Returns: `true`, если расстояние меньше или равно максимальному значению, `false` в противном случае.
    func isWithinDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double, maxDistanceInMeters: Double = Constants.Location.maxDistance) -> Bool {
        let location1 = CLLocation(latitude: lat1, longitude: lon1)
        let location2 = CLLocation(latitude: lat2, longitude: lon2)
        let distance = location1.distance(from: location2)
        return distance <= maxDistanceInMeters
    }
}

