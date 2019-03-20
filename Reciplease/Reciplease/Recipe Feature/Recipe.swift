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
    public let ingredientsList: [String]
    public let like: String
    public let time: String
    public let image: String
    public let id: String?
    public let rate: Int
}
