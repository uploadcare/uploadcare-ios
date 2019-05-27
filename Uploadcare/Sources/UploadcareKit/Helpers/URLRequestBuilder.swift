//
//  URLRequestBuilder.swift
//  Uploadcare
//
//  Created by Artem Loenko on 27/05/2019.
//  Copyright © 2019 Uploadcare. All rights reserved.
//

import Foundation

final class URLRequestBuilder {

    class func build(with path: String, queryItems: [ URLQueryItem ]?) -> URLRequest? {
        var components = self.baseComponents(with: path)
        components.queryItems = queryItems
        guard let url = components.url else { return nil }
        return URLRequest(url: url)
    }

    class func baseComponents(with path: String) -> URLComponents {
        var components = self.baseComponents
        components.path = path
        return components
    }

    static var baseComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = Configuration.API.scheme
        components.host = Configuration.API.host
        return components
    }()

}
