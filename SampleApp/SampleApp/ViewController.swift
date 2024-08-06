//
//  ViewController.swift
//  SampleApp
//
//  Created by Joseph Szymanski on 8/5/24.
//

import UIKit

class ViewController: UIViewController {
    var model = FoodModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

        let collectionViewController = CollectionViewcontroller(model: model)
        collectionViewController.willMove(toParent: self)
        collectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionViewController.view)
        addChild(collectionViewController)
        collectionViewController.didMove(toParent: self)

        collectionViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        collectionViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        collectionViewController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        collectionViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model.searchString = searchText
    }
}
