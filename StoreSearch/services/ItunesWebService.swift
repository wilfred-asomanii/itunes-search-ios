//
//  ItunesWebService.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

class ItunesWebService {
    private let itunesSearchURL = "https://itunes.apple.com/search?term="

    public func performSearch(for searchTerm: String,
                              onComplete: @escaping ([SearchResult]?, Error?) -> Void) {
        guard !searchTerm.isEmpty else { onComplete(nil, nil); return }
        let searchUrl = searchURL(for: searchTerm)
        do {
            let data = try Data(contentsOf: searchUrl)
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultData.self, from: data)
//            let sortedRes = result.results.sorted { $0 < $1 }
//            or
            let sortedRes = result.results.sorted(by: <)
            onComplete(sortedRes, nil)
        } catch {
            onComplete(nil, error)
        }
    }

    private func searchURL(for searchTerm: String) -> URL {
        let encodedString = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = itunesSearchURL + encodedString
        return URL(string: urlString)!
    }
}
