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
    var itunesWebService: ItunesWebService!
    var error: Error?

    override func viewDidLoad() {
        super.viewDidLoad()

        var cellNib = UINib(nibName: CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: CellIdentifiers.noSearchCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.noSearchCell)
        cellNib = UINib(nibName: CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: CellIdentifiers.errorCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.errorCell)
        tableView.contentInset = UIEdgeInsets(top: 52, left: 0, bottom: 0, right: 0)

        searchBar.becomeFirstResponder()
    }

    struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let noSearchCell = "NoSearchCell"
        static let errorCell = "ErrorCell"
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
        // this dequeue method works if you've registered a cell with the table view or have prototype cells
        guard error == nil else {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.errorCell, for: indexPath)
        }
        guard let searchResults = searchResults else {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.noSearchCell, for: indexPath)
        }
        guard searchResults.count != 0 else {
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.nothingFoundCell, for: indexPath)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        let result = searchResults[indexPath.row]
        cell.nameLabel?.text = result.name
        cell.artistNameLabel?.text = String(format: "%@ by %@", result.type, result.artist)
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
        error = nil
        itunesWebService.performSearch(for: searchTerm, onComplete: { [ weak self ] results, err in
            guard let self = self else { return }
            self.searchResults = results
            self.error = err
            self.tableView.reloadSections([0], with: .automatic)
            guard let _ = err else { return }
            let alert = UIAlertController(title: "Ooops", message: "Unable to network", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oh Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            }
        )
    }
}

