//
//  CitiesPageViewController+UIPageViewControllerDelegate.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 25.08.2024.
//

import UIKit

extension CitiesPageViewController: UIPageViewControllerDelegate {
    
    // MARK: - Page Transition Handling
    
    /// Обработка завершения анимации перехода между страницами.
    /// - Parameters:
    ///   - pageViewController: Экземпляр UIPageViewController.
    ///   - finished: Булевое значение, показывающее, завершена ли анимация.
    ///   - previousViewControllers: Массив контроллеров, отображавшихся до завершения перехода.
    ///   - completed: Булевое значение, показывающее, завершен ли переход.
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = viewControllers?.first as? WeatherViewController {
            if let index = citiesViewModel.cities.firstIndex(where: { $0.id == currentVC.weatherViewModel.cityId }) {
                citiesViewModel.setCurrentCityIndex(to: index)
                citiesPageView.pageControl.currentPage = index
                
                // Обновляем изображения для точек
                updatePageControlImages()
            }
        }
    }
}

         
