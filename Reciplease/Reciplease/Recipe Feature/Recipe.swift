//
//  Recipe.swift
//  Reciplease
//
//  Created by Christophe Bugnon on 19/03/2019.
//  Copyright © 2019 Christophe Bugnon. All rights reserved.
//

import Foundation

public struct Recipe: Equatable {
    public let name: String
    public let ingredients: [String]
    public let id: String?
    public let rate: Int
    public let time: Int
    public let imageURL: URL

    public init(name: String, ingredients: [String], id: String?, rate: Int, time: Int, imageURL: URL) {
        self.name = name
        self.ingredients = ingredients
        self.id = id
        self.rate = rate
        self.time = time
        self.imageURL = imageURL
    }
}

extension Recipe: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ingredients, id, imageUrlsBySize
        case name = "recipeName"
        case rate = "rating"
        case time = "totalTimeInSeconds"
    }

    private enum ImageURLCodingKeys: String, CodingKey {
        case imageURL = "90"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageURLContainer = try container.nestedContainer(keyedBy: ImageURLCodingKeys.self, forKey: .imageUrlsBySize)

        name = try container.decode(String.self, forKey: .name)
        ingredients = try container.decode([String].self, forKey: .ingredients)
        rate = try container.decode(Int.self, forKey: .rate)
        time = try container.decode(Int.self, forKey: .time)

        id = try container.decodeIfPresent(String.self, forKey: .id)

        imageURL = try imageURLContainer.decode(URL.self, forKey: .imageURL)
    }
}
