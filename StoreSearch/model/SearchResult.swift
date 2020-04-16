//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

struct ResultData: Codable {
    let resultCount: Int
    let results: [SearchResult]
}

// CustomStringConvertible allows classes etc to have custom string representations
// simillar to java's toString method. but with this, you "override" 'description'
struct SearchResult: Codable, CustomStringConvertible {
    let artistName: String?
    let trackName: String?
    let kind: String?
    let trackPrice: Double?
    let currency: String?
    let imageSmall: String?
    let imageLarge: String?
    let trackViewUrl: String?
    let collectionName: String?
    let collectionViewUrl: String?
    let collectionPrice: Double?
    let itemPrice: Double?
    let itemGenre: String?
    let bookGenre: [String]?

    // this enum shows the decoder the original json names of the corresponding properties in this class
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case artistName, currency, kind
        case trackPrice, trackName, trackViewUrl
        case collectionName, collectionPrice, collectionViewUrl
    }

    var name: String {
        return trackName ?? collectionName ?? "Unknown Piece"
    }

    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }

    var price: Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0 }

    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return "Unknown Genre"
    }

    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: break
        }
        return "Unknown"
    }

    var artist: String {
        return artistName ?? "Unknown Artist"
    }

    // description from CustomStringConvertible
    var description: String {
        return "Name: \(name), Artist Name: \(artistName ?? "N/A")"
    }
}

// operator overloading
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedDescending
}
