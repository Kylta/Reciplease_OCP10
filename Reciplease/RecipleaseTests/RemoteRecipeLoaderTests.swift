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

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
    }
}

class HTTPClient {
    var requestedURLs = [URL]()

    func get(from url: URL) {
        requestedURLs.append(url)
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

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func makeSUT(url: URL = URL(string: "any-url.com")!) -> (sut: RemoteRecipeLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteRecipeLoader(url: url, client: client)
        return (sut, client)
    }
}
