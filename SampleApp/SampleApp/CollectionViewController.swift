//
//  CollectionViewController.swift
//  SampleApp
//
//  Created by Joseph Szymanski on 8/5/24.
//

import Combine
import UIKit

class CollectionViewcontroller: UIViewController {
    private var subscribers = Set<AnyCancellable>()
    private var model: FoodModel
    private var collectionView: UICollectionView!
    private var diffableDataSource: UICollectionViewDiffableDataSource<ListSection, Food.ID>!
    private enum ListSection: Int {
        case main
    }

    init(model: FoodModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        configure()
        model.$foodArray.sink { [weak self] foodArray in
            DispatchQueue.main.async { [weak self] in
                self?.processUpdate()
            }
        }
        .store(in: &subscribers)

        model.$loading.sink { [weak self] loading in
            if loading {
                DispatchQueue.main.async { [weak self] in
                    self?.setNeedsUpdateContentUnavailableConfiguration()
                }
            }
        }
        .store(in: &subscribers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: Look into https://swiftsenpai.com/development/using-uicontentunavailableconfiguration/
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        // Remove existing configuration (if exist)
        contentUnavailableConfiguration = nil
        if model.loading {
            showLoading()
        } else if let foodArray = model.foodArray, foodArray.count == 0 {
            showEmpty()
        } else if model.foodArray == nil {
            showLanding()
        }
    }

    // TODO: https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/updating_collection_views_using_diffable_data_sources
    private func configure() {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        view.addSubview(collectionView)

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Food> { cell, indexPath, food in
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = food.name
            contentConfiguration.secondaryText = food.brand
            cell.contentConfiguration = contentConfiguration
        }
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [weak self] collectionView, indexPath, itemIdentifier in
            let food = self?.model.foodArray?[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: food)
        }
        diffableDataSource.apply(NSDiffableDataSourceSnapshot<ListSection, Food.ID>(), animatingDifferences: false)
        showLanding()
    }

    private func processUpdate() {
        var snapshot = NSDiffableDataSourceSnapshot<ListSection, Food.ID>()
        snapshot.appendSections([ListSection.main])
        if let foodArray = model.foodArray {
            snapshot.appendItems(foodArray.map { $0.id }, toSection: ListSection.main)
        }
        diffableDataSource.apply(snapshot)
        setNeedsUpdateContentUnavailableConfiguration()
    }
    
    private func showLanding() {
        var config = UIContentUnavailableConfiguration.empty()
        config.text = "Enter a search term of at least 3 characters"
        config.textProperties.font = .boldSystemFont(ofSize: 18)
        contentUnavailableConfiguration = config
    }

    private func showLoading() {
        var config = UIContentUnavailableConfiguration.loading()
        config.text = "Loading, please wait..."
        config.textProperties.font = .boldSystemFont(ofSize: 18)
        contentUnavailableConfiguration = config
    }

    private func showEmpty() {
        var emptyConfig = UIContentUnavailableConfiguration.empty()
        emptyConfig.image = UIImage(systemName: "exclamationmark.circle.fill")
        emptyConfig.text = "No result found."
        emptyConfig.secondaryText = "Please try a different search."
        contentUnavailableConfiguration = emptyConfig
    }
    
    private func showError() {
        var errorConfig = UIContentUnavailableConfiguration.empty()
        errorConfig.image = UIImage(systemName: "exclamationmark.circle.fill")
        errorConfig.text = "Something went wrong."
        errorConfig.secondaryText = "Please try again later."
        
        var retryButtonConfig = UIButton.Configuration.borderless()
        retryButtonConfig.image = UIImage(systemName: "arrow.clockwise.circle.fill")
        errorConfig.button = retryButtonConfig
        
        // Define the reload button action
        errorConfig.buttonProperties.primaryAction = UIAction.init(handler: { _ in
            // TODO: hook up retry button?
        })
        contentUnavailableConfiguration = errorConfig
    }
}

extension CollectionViewcontroller: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let food = model.foodArray?[indexPath.item] else { return }
        
        let controller = UIAlertController(
            title: nil,
            message: "\(food.name) from \(food.brand)",
            preferredStyle: .alert
        )
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController?.present(controller, animated: true)
    }
}
