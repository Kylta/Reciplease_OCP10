//
//  RecipeLoader.swift
//  Reciplease
//
//  Created by Christophe Bugnon on 19/03/2019.
//  Copyright © 2019 Christophe Bugnon. All rights reserved.
//

import Foundation

enum LoadRecipeResult {
    case success([Recipe])
    case failure(Error)
}

protocol RecipeLoader {
    func load(completion: @escaping (LoadRecipeResult) -> Void)
}
