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
        let client = HTTPClient()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "any-url.com")!
        let client = HTTPClient()
        let sut = RemoteRecipeLoader(url: url, client: client)

        sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }
}
