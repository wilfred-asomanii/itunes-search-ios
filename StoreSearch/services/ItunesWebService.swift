//
//  ItunesWebService.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

class ItunesWebService {
    private let itunesSearchURL = "https://itunes.apple.com/search?country=gh&term="

    private lazy var urlSession: URLSession = {
        let session = URLSession.shared
        //        session.configuration.httpAdditionalHeaders = []
        session.configuration.timeoutIntervalForRequest = 5
        return session
    }()
    private var dataTask: URLSessionDataTask?

    public func performSearch(for searchTerm: String,
                              in filter: Int,
                              onComplete: @escaping ([SearchResult]?, Error?) -> Void) {
        guard !searchTerm.isEmpty else { onComplete(nil, nil); return }
        let searchUrl = self.searchURL(for: searchTerm, in: filter)
        dataTask?.cancel()
        dataTask = urlSession.dataTask(with: searchUrl) {
            [weak self] data, response, err in
            let error = err as NSError?
            guard let self = self else { return }
            guard error == nil else {
                guard error!.code != -999 else { return /* canceled */}
                self.runOnMain(onComplete, nil, error)
                return
            }
            guard let data = data else { self.runOnMain(onComplete, [], nil); return }
            guard validateStatus(of: response) else { self.runOnMain(onComplete, nil, NSError(domain: "Internet", code: 999)); return }
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(ResultData.self, from: data)
                self.runOnMain(onComplete, result.results, nil)
            } catch {
                self.runOnMain(onComplete, nil, error)
            }
        }
        dataTask!.resume()
    }

    private func runOnMain(_ closure: @escaping ([SearchResult]?, Error?) -> Void,
                           _ results: [SearchResult]?, _ error: Error?) {
        DispatchQueue.main.async {
            closure(results, error)
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
