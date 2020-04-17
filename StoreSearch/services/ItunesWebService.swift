//
//  ItunesWebService.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

typealias SearchComplete = (SearchState) -> Void

enum SearchState {
    case notSearched
    case loading
    case noResults
    case error
    case results([SearchResult])
}

class ItunesWebService {
    private let itunesSearchURL = "https://itunes.apple.com/search?country=gh&term="

    private lazy var urlSession: URLSession = {
        let session = URLSession.shared
        //        session.configuration.httpAdditionalHeaders = []
        session.configuration.timeoutIntervalForRequest = 5
        return session
    }()
    private var getRequest: (URL) -> URLRequest = { url in
        var getRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
        getRequest.httpMethod = "GET"
        return getRequest
    }
    private var dataTask: URLSessionDataTask?

    public func performSearch(for searchTerm: String, in filter: Int,
                              onComplete: @escaping SearchComplete) {
        guard !searchTerm.isEmpty else { onComplete(.notSearched); return }
        let searchUrl = self.searchURL(for: searchTerm, in: filter)
        dataTask?.cancel()
        dataTask = urlSession.dataTask(with: getRequest(searchUrl)) {
            [weak self] data, response, err in
            let error = err as NSError?
            guard let self = self else { return }
            guard error == nil else {
                guard error!.code != -999 else { return /* canceled */}
                self.runOnMain(onComplete, .error)
                return
            }
            guard let data = data else { self.runOnMain(onComplete, .noResults); return }
            guard validateStatus(of: response) else { self.runOnMain(onComplete, .error); return }
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(ResultData.self, from: data)
                guard result.results.count > 0 else { self.runOnMain(onComplete, .noResults); return}
                self.runOnMain(onComplete, .results(result.results))
            } catch {
                self.runOnMain(onComplete, .error)
            }
        }
        dataTask!.resume()
    }

    private func runOnMain(_ closure: @escaping SearchComplete,
                           _ state: SearchState) {
        DispatchQueue.main.async {
            closure(state)
        }
    }

    private func searchURL(for searchTerm: String, in filter: Int) -> URL {
        let kind: String
        switch filter {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        let encodedString = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "\(itunesSearchURL)\(encodedString)&entity=\(kind)"
        return URL(string: urlString)!
    }
}

func validateStatus(of response: URLResponse?) -> Bool {
    let res = response as? HTTPURLResponse
    return res != nil &&
        res!.statusCode >= 200 &&
        res!.statusCode <= 300
}
