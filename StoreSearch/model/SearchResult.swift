//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

class SearchResult: NSObject, Codable {

    var name: String
    var artistName: String

    init(name: String, artistName: String) {
        self.name = name
        self.artistName = artistName
    }
}
