//
//  RemoteRecipeLoaderTests.swift
//  RecipleaseTests
//
//  Created by Christophe Bugnon on 19/03/2019.
//  Copyright © 2019 Christophe Bugnon. All rights reserved.
//

import XCTest
import Reciplease

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

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
            case .success:
                completion(.failure(.invalidData))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

public class HTTPClient {
    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, response))
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

        expect(sut: sut, whenCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut: sut, whenCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut: sut, whenCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data(bytes: "invalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func makeSUT(url: URL = URL(string: "any-url.com")!) -> (sut: RemoteRecipeLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteRecipeLoader(url: url, client: client)
        return (sut, client)
    }

    func expect(sut: RemoteRecipeLoader, whenCompleteWith result: RemoteRecipeLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteRecipeLoader.Result]()

        sut.load { capturedResults.append($0) }

        action()

        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
}
