//
//  RemoteRecipeLoader.swift
//  Reciplease
//
//  Created by Christophe Bugnon on 20/03/2019.
//  Copyright © 2019 Christophe Bugnon. All rights reserved.
//

import Foundation

public class RemoteRecipeLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([Recipe])
        case failure(Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                completion(RecipeItemMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
