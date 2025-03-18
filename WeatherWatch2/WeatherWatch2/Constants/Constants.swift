//
//  Constants.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 14.09.2024.
//

import UIKit

// MARK: - Constants

enum Constants {
    
    // MARK: - App Colors
    enum Colors {
        static let background = UIColor.systemBackground
        static let primaryAccent = UIColor(red: 234/255, green: 120/255, blue: 34/255, alpha: 1.0)
        static let primaryText = UIColor.label
        static let secondaryText = UIColor.secondaryLabel
        static let separator = UIColor.separator
        static let lightGrayWithAlpha = UIColor.lightGray.withAlphaComponent(0.2)
    }
    
    // MARK: - Fonts
    enum Fonts {
        static let loadingLabelDescription = UIFont.systemFont(ofSize: 18)
        static let appName = UIFont.boldSystemFont(ofSize: 20)
        static let cityTitle = UIFont.boldSystemFont(ofSize: 24)
        static let temperature = UIFont.systemFont(ofSize: 64, weight: .thin)
        static let smallDetails = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    // MARK: - Dimensions and Spacing
    enum Dimensions {
        // Основные размеры
        static let logoWidth: CGFloat = 100
        static let logoHeight: CGFloat = 100
        static let buttonSize: CGFloat = 44
        static let iconSizeSmall: CGFloat = 30
        static let iconSizeMedium: CGFloat = 40
        static let lineHeight: CGFloat = 1
        
        // Интервалы отступов
        static let paddingSmall: CGFloat = 8
        static let paddingMedium: CGFloat = 16
        static let paddingLarge: CGFloat = 20
        static let paddingXLarge: CGFloat = 36
        
        // Размеры контролов
        static let pageControlHeight: CGFloat = 26
        static let cityLabelTopMargin: CGFloat = 36
        static let scrollViewBottomMargin: CGFloat = 35
        
        // Размеры коллекций и таблиц
        static let hourlyCollectionHeight: CGFloat = 100
        static let dailyTableHeight: CGFloat = 300
        static let collectionCellWidth: CGFloat = 60
        static let collectionCellHeight: CGFloat = 80
        static let tableRowHeight: CGFloat = 60
        
        // Высота других элементов
        static let sunTimesContainerHeight: CGFloat = 30
        static let weatherDetailsContainerHeight: CGFloat = 30
        static let citiesPageViewHeight: CGFloat = 50
    }
    
    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 10
        static let largeEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        static let smallEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    // MARK: - Localized Texts
    enum Strings {
        // Основные сообщения
        static let loading = "Fetching the weather...".localized
        static let appName = "Weather Watch"
        static let noInternetTitle = "No Internet Connection".localized
        static let noInternetMessage = "Check your connection and try again.".localized
        
        // Параметры погоды
        static let sunrise = "Sunrise".localized
        static let sunset = "Sunset".localized
        static let wind = "Wind".localized
        static let humidity = "Humidity".localized
        static let pressure = "Pressure".localized
        
        // Прочее
        static let hourlyNow = "Now".localized
        static let feelsLike = "Feels like".localized
        static let defaultIcon = "default_icon"
        static let timePlaceholder = "00:00"
        static let emptyPlaceholder = " "
        static let percentageSymbol = "%"
        static let valueSeparator = ": "
        
        // Поиск и редактирование
        static let editButtonTitle = "Edit".localized
        static let doneButtonTitle = "Done".localized
        static let searchPlaceholder = "Search city".localized
        static let currentLocationSuffix = " - Current Location".localized
        static let cityAlreadyExistsTitle = "City already exists".localized
        static let cityAlreadyExistsMessage = "%@ is already in your list.".localized
        static let cityListOK = "OK"
        
        // Настройки
        static let weatherLabelTitle = "Weather".localized
        static let settingsTitle = "Settings".localized
        static let temperatureLabel = "Temperature".localized
        static let windSpeedLabel = "Wind Speed".localized
        static let pressureLabel = "PressureSetting".localized
        static let themeLabel = "Theme".localized
        static let celsiusUnit = "°C"
        static let fahrenheitUnit = "°F"
        static let meterPerSecondUnit = "m/s".localized
        static let kmPerHourUnit = "km/h".localized
        static let mphSettingsUnit = "mphSettings".localized
        static let knotsSettingsUnit = "knotsSettings".localized
        static let mphUnit = "mph".localized
        static let knotsUnit = "knots".localized
        static let hPaUnit = "hPa".localized
        static let mmHgUnit = "mmHg".localized
        static let mbarUnit = "mbar".localized
        static let inHgUnit = "inHg".localized
        static let inHgSettingsUnit = "inHgSettings".localized
        static let lightTheme = "Light".localized
        static let darkTheme = "Dark".localized
    }
    
    // MARK: - Location Settings
    enum Location {
        static let maxDistance: Double = 10000 // 10 км - максимальное расстояние для поиска городов
    }
    
    // MARK: - Forecast Settings
    enum Forecast {
        static let hourlyRange = 1..<48 // Диапазон для прогноза на 47 часов
    }
    
    // MARK: - Animation
    enum Animation {
        static let durationShort = 0.3
    }
    
    // MARK: - Image Assets
    enum Images {
        static let appIcon = UIImage(named: "AppIcon")
        static let locationIcon = UIImage(systemName: "location.fill")
        static let menuIcon = UIImage(systemName: "list.bullet")
        static let settingsIcon = UIImage(systemName: "gearshape")
    }
    
    // MARK: - API Configurations
    enum API {
        static let weatherAPIKey = "API_KEY"
        
        static let scheme = "https"
        static let host = "api.openweathermap.org"
        static let forecastPath = "/data/2.5/forecast"
        static let geoPath = "/geo/1.0/direct"
        
        // Названия параметров запроса
        static let latitudeParam = "lat"
        static let longitudeParam = "lon"
        static let apiKeyParam = "appid"
        static let unitsParam = "units"
        static let langParam = "lang"
        static let queryParam = "q"
        static let limitParam = "limit"
        
        // Другие настройки
        static let units = "metric"
        static let resultLimit = "5"
        static let iconHost = "openweathermap.org"
        static let iconPath = "/img/wn/"
        static let iconExtension = "@2x.png"
    }
    
    // MARK: - Localization Keys
    enum LocalizationKeys {
        static let ru = "ru"
        static let en = "en"
    }
    
    // MARK: - JSON Keys
    enum JSONKeys {
        static let name = "name"
        static let country = "country"
        static let state = "state"
        static let lat = "lat"
        static let lon = "lon"
        static let localNames = "local_names"
    }
    
    // MARK: - Format Strings
    enum FormatStrings {
        static let twoDecimalFormat = "%.2f"
    }
    
    // MARK: - Realm
    enum Realm {
        static let schemaVersion: UInt64 = 6
        
        // Описатели миграций
        static let orderDescriptors = "order"
        static let latitudeDescriptors = "latitude"
        static let longitudeDescriptors = "longitude"
        static let isCurrentLocationDescriptors = "isCurrentLocation"
        static let localNameEnDescriptors = "localNameEn"
        static let localNameRuDescriptors = "localNameRu"
        
        // Запросы
        static let currentLocationQuery = "isCurrentLocation == true"
        static let cityWithoutCoordinatesOrNamesQuery = "(latitude == 0.0 AND longitude == 0.0) OR localNameEn == nil OR localNameRu == nil"
    }
    
    // MARK: - User Defaults Keys
    enum UserDefaultsKeys {
        static let lastSelectedCityId = "lastSelectedCityId"
        static let temperatureUnit = "temperatureUnit"
        static let windSpeedUnit = "windSpeedUnit"
        static let pressureUnit = "pressureUnit"
        static let theme = "theme"
    }
    
    // MARK: - Timezone Offset
    enum DateConstants {
        static let timezoneOffset: TimeInterval = 10800
    }
    
    // MARK: - Date Format Patterns
    enum DateFormat {
        static let fullDateTime = "yyyy-MM-dd HH:mm:ss"
        static let timeOnly = "HH:mm"
        static let dayMonth = "MMM dd"
        static let weekdayAndDate = LocalizationHelper.isRussian ? "E, MMM dd" : "E MMM dd"
        static let dayKey = "yyyy-MM-dd"
    }
    
    // MARK: - Notification Names
    enum Notifications {
        static let settingsChanged = NSNotification.Name("SettingsChanged")
    }
}
