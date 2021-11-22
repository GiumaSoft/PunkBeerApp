//
//  UITableView.swift
//  PokemonApp
//
//  Created by Giuseppe Mazzilli on 15/01/2021.
//

import UIKit

extension UITableView {

    /**
     * Register a nib object containing a cell with the table view using class name identifier
     */
    func register(cellNibClass: UITableViewCell.Type) {
        self.register(UINib(nibName: "\(cellNibClass.self)", bundle: Bundle.main), forCellReuseIdentifier: "\(cellNibClass.self)")
    }
    /**
     * Register a nib object containing a header or footer with the table view using class name identifier
     */
    func register(headerFooterNibClass: UITableViewHeaderFooterView.Type) {
        self.register(UINib(nibName: "\(headerFooterNibClass.self)", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "\(headerFooterNibClass.self)")
    }
    
    
    func dequeueReusableCell<T: UITableViewCell>(fromClass: T.Type) -> T? {
        self.dequeueReusableCell(withIdentifier: "\(T.self)") as? T
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(fromClass: T.Type) -> T? {
        self.dequeueReusableHeaderFooterView(withIdentifier: "\(T.self)") as? T
    }
    
}
