//
//  NetworkError.swift
//  WeatherWatch
//
//  Created by Evgeniy Fakhretdinov on 13.09.2024.
//

import Foundation

/// `NetworkError` описывает типы сетевых ошибок, которые могут возникать в приложении.
/// Эти ошибки используются для обработки различных сетевых проблем и ошибок на уровне HTTP-запросов.
///
/// `NetworkError` включает в себя:
/// - Ошибки клиента: проблемы с запросами, такие как `badRequest`, `unauthorized` и т.д.
/// - Ошибки сервера: например, `internalServerError` и другие.
/// - Сетевые ошибки: такие как `noInternetConnection` и `timeout`.
///
/// Также содержит:
/// - Localized description: удобное описание ошибки.
/// - Метод для создания ошибки по коду состояния HTTP: упрощает создание ошибки на основе кода ответа сервера.
enum NetworkError: Error {
    
    // MARK: - Client Errors
    
    case badRequest // 400
    case unauthorized // 401
    case forbidden // 403
    case notFound // 404
    case tooManyRequests // 429
    
    // MARK: - Server Errors
    
    case internalServerError // 500
    case badGateway // 502
    case serviceUnavailable // 503
    case gatewayTimeout // 504
    
    // MARK: - Connection and Other Errors
    
    case noInternetConnection
    case timeout
    case unknownError
    case decodingError(description: String)
    
    // MARK: - Description
    
    /// Локализованное описание для каждой ошибки.
    var description: String {
        switch self {
        case .badRequest:
            return "error_bad_request".localized
        case .unauthorized:
            return "error_unauthorized".localized
        case .forbidden:
            return "error_forbidden".localized
        case .notFound:
            return "error_not_found".localized
        case .tooManyRequests:
            return "error_too_many_requests".localized
        case .internalServerError:
            return "error_internal_server_error".localized
        case .badGateway:
            return "error_bad_gateway".localized
        case .serviceUnavailable:
            return "error_service_unavailable".localized
        case .gatewayTimeout:
            return "error_gateway_timeout".localized
        case .noInternetConnection:
            return "error_no_internet_connection".localized
        case .timeout:
            return "error_timeout".localized
        case .unknownError:
            return "error_unknown".localized
        case .decodingError(let description):
            return String(format: "error_decoding".localized, description)
        }
    }
    
    // MARK: - HTTP Error Mapping
    
    /// Создает ошибку на основе кода состояния HTTP.
    /// - Parameter statusCode: Код состояния HTTP.
    /// - Returns: Соответствующий `NetworkError`.
    static func error(from statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 429: return .tooManyRequests
        case 500: return .internalServerError
        case 502: return .badGateway
        case 503: return .serviceUnavailable
        case 504: return .gatewayTimeout
        default: return .unknownError
        }
    }
}


