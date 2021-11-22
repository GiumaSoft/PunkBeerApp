//
//  SearchViewModel.swift
//  PunkApp
//
//  Created by Giuseppe Mazzilli on 20/11/21.
//

import Foundation
import UIKit

class SearchViewModel {
    
    enum Section: Int {
        case Beer = 1
        
        init(_ indexPath: IndexPath) {
            switch indexPath.section {
            default: self = .Beer
            }
        }
    }
    
    private var nm = PunkApiService()
    private var filterString = String() {
        didSet { (ds = ds) }
    }
    private var ds = [PunkBeer]() {
        didSet {
            if filterString.isEmpty {
                filteredDS = ds
            } else {
                filteredDS = ds.filter { beer in
                    beer.name
                        .lowercased()
                        .range(of: filterString.lowercased()) != nil
                }
            }
        }
    }
    
    private var fetchInProgress = Bool(false)
    private var selectedBeer: PunkBeer?
    private var currentPage = Int(1)
    private var filteredDS = [PunkBeer]()
    

    func initialBatch(completion: @escaping () -> Void) {
        nm.getBeers(page: 1) { beers in
            self.ds = beers
            completion()
        }
    }

    func nextBatch(page: Int, completion: @escaping () -> Void) {
        nm.getBeers(page: page) { beers in
            self.ds.append(contentsOf: beers)
            completion()
        }
    }
    
    func fetchData(completion: @escaping () -> Void) {
        if fetchInProgress == false {
            fetchInProgress = true
            nm.getBeers(page: currentPage) { [weak self] beers in
                self?.fetchInProgress = false
                print("Prefetch beers count ", beers.count)
                if !beers.isEmpty {
                    self?.currentPage += 1
                    self?.ds.append(contentsOf: beers)
                    completion()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredDS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(indexPath) {
        default:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "BeerTableViewCell") as? BeerTableViewCell {
                let beer = filteredDS[indexPath.item]
                if let imageData = beer.imageData {
                    cell.beerImage.image = UIImage(data: imageData)
                }
                cell.beerName.text = beer.name
                cell.beerAbv.text = "\("alcohol.content".localized): \(beer.abv.description)"
                cell.beerIbu.text = "IBU: \(beer.ibu?.description ?? "")"
                cell.beerDescription.text = beer.description
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBeer = filteredDS[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("Attempt to prefetch data")
        if fetchInProgress == false {
            fetchInProgress = true
            nm.getBeers(page: currentPage + 1) { [weak self] beers in
                self?.fetchInProgress = false
                if !beers.isEmpty {
                    self?.currentPage += 1
                    self?.ds.append(contentsOf: beers)
                    tableView.reloadData()
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterString = searchText
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailsViewController = segue.destination as? BeerDetailsViewController else { return }
        detailsViewController.beer = selectedBeer
    }
    
}
