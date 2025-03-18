//
//  CitiesPageViewController+CitiesListViewControllerDelegate.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 04.09.2024.
//

import UIKit

extension CitiesPageViewController: CitiesListViewControllerDelegate {
    
    // MARK: - Cities List Update
    
    /// Обновление списка городов.
    /// - Parameter updatedCities: Массив объектов CityObject с обновленными данными о городах.
    func didUpdateCities(_ updatedCities: [CityObject]) {
        citiesViewModel.cities = updatedCities
        // Обновляем PageControl для нового списка городов
        citiesPageView.pageControl.numberOfPages = updatedCities.count
    }
    
    // MARK: - City Selection Handling
    
    /// Обработка выбора города из списка.
    /// - Parameter index: Индекс выбранного города.
    func didSelectCity(at index: Int) {
        let direction: UIPageViewController.NavigationDirection = index > citiesViewModel.currentIndex ? .forward : .reverse
        citiesViewModel.setCurrentCityIndex(to: index)
        
        if let selectedVC = createWeatherViewController(for: citiesViewModel.currentCity, from: .citiesPage) {
            setViewControllers([selectedVC], direction: direction, animated: false, completion: { [weak self] completed in
                if completed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.citiesPageView.pageControl.currentPage = index
                        self?.citiesPageView.pageControl.layoutIfNeeded()
                        
                        // Обновляем изображения для точек
                        self?.updatePageControlImages()
                    }
                }
            })
        }
    }
}

