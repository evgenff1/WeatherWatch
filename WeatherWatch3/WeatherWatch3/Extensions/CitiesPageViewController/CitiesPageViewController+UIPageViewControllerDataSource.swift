//
//  CitiesPageViewController+UIPageViewControllerDataSource.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

extension CitiesPageViewController: UIPageViewControllerDataSource {
    
    // MARK: - Page Navigation (Before)
    
    /// Метод для получения контроллера предыдущей страницы.
    /// - Parameters:
    ///   - pageViewController: Контроллер, отображающий текущую страницу.
    ///   - viewController: Текущий контроллер.
    /// - Returns: Контроллер для предыдущей страницы или `nil`, если страницы нет.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = citiesViewModel.currentIndex
        let previousIndex = currentIndex - 1
        
        if previousIndex < 0 {
            return nil
        }
        
        if let previousCity = citiesViewModel.city(at: previousIndex) {
            return createWeatherViewController(for: previousCity, from: .citiesPage)
        }
        
        return nil
    }
    
    // MARK: - Page Navigation (After)
    
    /// Метод для получения контроллера следующей страницы.
    /// - Parameters:
    ///   - pageViewController: Контроллер, отображающий текущую страницу.
    ///   - viewController: Текущий контроллер.
    /// - Returns: Контроллер для следующей страницы или `nil`, если страницы нет.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = citiesViewModel.currentIndex
        let nextIndex = currentIndex + 1
        
        guard nextIndex < citiesViewModel.numberOfCities else { return nil }
        
        if let nextCity = citiesViewModel.city(at: nextIndex) {
            return createWeatherViewController(for: nextCity, from: .citiesPage)
        }
        
        return nil
    }
}


