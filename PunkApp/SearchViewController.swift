//
//  SearchViewController.swift
//  PunkApp
//
//  Created by Giuseppe Mazzilli on 20/11/21.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private var model = SearchViewModel()
    private var beer: PunkBeer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PunkBeer App"
        
        tableView.register(cellNibClass: BeerTableViewCell.self)
        
        activityView.startAnimating()
        model.initialBatch { [weak self] in
            self?.activityView.stopAnimating()
            self?.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        model.prepare(for: segue, sender: sender)
    }

}

extension SearchViewController: UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        model.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.tableView(tableView, didSelectRowAt: indexPath)
        self.performSegue(withIdentifier: "DetailsView", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        model.tableView(tableView, prefetchRowsAt: indexPaths)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model.searchBar(searchBar, textDidChange: searchText)
        tableView.reloadData()
    }

}
