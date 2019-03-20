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
