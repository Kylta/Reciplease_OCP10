//
//  RemoteRecipeLoaderTests.swift
//  RecipleaseTests
//
//  Created by Christophe Bugnon on 19/03/2019.
//  Copyright © 2019 Christophe Bugnon. All rights reserved.
//

import XCTest
import Reciplease

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

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: makeJSON(), at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data(bytes: "invalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = Data(bytes: "{\"matches\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(name: "a name", ingredients: ["any ingredients"], id: "an id", rate: 4, time: 60, imageURL: URL(string: "image-url.com")!)
        let item2 = makeItem(name: "another name", ingredients: ["another ingredients"], id: nil, rate: 1, time: 600, imageURL: URL(string: "another-image-url.com")!)

        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            client.complete(withStatusCode: 200, data: makeJSON())
        })
    }

    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteRecipeLoader? = RemoteRecipeLoader(url: url, client: client)

        var capturedResults = [RemoteRecipeLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeJSON())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    fileprivate func makeSUT(url: URL = URL(string: "any-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteRecipeLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRecipeLoader(url: url, client: client)
        trackForMemoryLeaks(instance: client, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, client)
    }

    fileprivate func failure(_ error: RemoteRecipeLoader.Error) -> RemoteRecipeLoader.Result {
        return .failure(error)
    }

    func trackForMemoryLeaks(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leaks.", file: file, line: line)
        }
    }

    fileprivate func makeItem(name: String, ingredients: [String], id: String? = nil, rate: Int, time: Int, imageURL: URL) -> Recipe {
        let item = Recipe(name: name, ingredients: ingredients, id: id, rate: rate, time: time, imageURL: imageURL)

        return item
    }

    fileprivate func makeJSON() -> Data {
        let filePath = Bundle(for: type(of: self)).url(forResource: "recipe", withExtension: "json")!
        return try! Data(contentsOf: filePath)
    }

    fileprivate func expect(_ sut: RemoteRecipeLoader, toCompleteWith expectedResult: RemoteRecipeLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (.failure(receivedError as RemoteRecipeLoader.Error), .failure(expectedError as RemoteRecipeLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    fileprivate class HTTPClientSpy: HTTPClient {
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

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
