//
//  RemoteRecipeLoaderTests.swift
//  RecipleaseTests
//
//  Created by Christophe Bugnon on 19/03/2019.
//  Copyright © 2019 Christophe Bugnon. All rights reserved.
//

import XCTest

class RemoteRecipeLoader {
    let url: URL
    let client: HTTPClient

    enum Error: Swift.Error {
        case connectivity
    }

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { _ in
            completion(.connectivity)
        }
    }
}

class HTTPClient {
    var requestedURLs = [URL]()
    var completions = [(Error) -> Void]()

    func get(from url: URL, completion: @escaping (Error) -> Void) {
        requestedURLs.append(url)
        completions.append(completion)
    }
}

class RemoteRecipeLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "another-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "another-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteRecipeLoader.Error]()

        sut.load { capturedErrors.append($0) }
        let clientError = NSError(domain: "test", code: 0)
        client.completions[0](clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    func makeSUT(url: URL = URL(string: "any-url.com")!) -> (sut: RemoteRecipeLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteRecipeLoader(url: url, client: client)
        return (sut, client)
    }
}
