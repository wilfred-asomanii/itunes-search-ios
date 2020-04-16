//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 16/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var searchResults: [SearchResult]?
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 52, left: 0, bottom: 0, right: 0)
    }


}

// Search and tableview datasource
extension SearchViewController: UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchResults = searchResults, searchResults.count != 0 else { return 1 }
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
        guard let searchResults = searchResults else {
            cell.textLabel?.text = "Nothing Searched Yet"
            return cell
        }
        guard searchResults.count != 0 else {
            cell.textLabel?.text = "No Search Results"
            return cell
        }
        cell.textLabel?.text = searchResults[indexPath.row].name
        cell.detailTextLabel?.text = searchResults[indexPath.row].artistName
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let searchResults = searchResults,
            searchResults.count != 0 else { return nil }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(for: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { [weak self] t in
            t.invalidate()
            self?.performSearch(for: searchText)
        }
    }

    func performSearch(for searchTerm: String) {
        searchResults = []
        guard !searchTerm.isEmpty else { tableView.reloadData(); return }
        for i in 1...10 {
            searchResults!.append(SearchResult(name: String(format: "Result %d", i), artistName: String(format: "For %@", searchTerm)))
        }
        tableView.reloadData()
    }
}

