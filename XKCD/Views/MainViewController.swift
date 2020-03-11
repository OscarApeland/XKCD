//
//  ViewController.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit
import RealmSwift

class MainNavigationController: UINavigationController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hidesBarsOnSwipe = true
        
        delegate = self as? UINavigationControllerDelegate
        
        view.backgroundColor = .systemBackground
        
        navigationBar.setValue(true, forKey: ["hides", "Shadow"].joined())
        navigationBar.barTintColor = .systemBackground
        navigationBar.tintColor = .label
    }
}

class MainViewController: ContentViewController {

    
    // MARK: State
    
    var isShowingSaved = false
    
    
    // MARK: Accessories
    
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    lazy var refreshControl = UIRefreshControl()
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(savedButtonPressed))
        
        searchController.searchBar.placeholder = "Find XKCD"
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        refreshControl.addTarget(self, action: #selector(refreshed), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        proxies = [
            FeedSectionProxy(feedType: .all)
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshControl.beginRefreshing()
        ComicFetcher.refreshComics {
            self.refreshControl.endRefreshing()
        }
    }
    
    
    // MARK: Actions
    
    @objc private func refreshed() {
        ComicFetcher.refreshComics {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func savedButtonPressed(_ sender: UIBarButtonItem) {
        UISelectionFeedbackGenerator().selectionChanged()
        
        isShowingSaved = !isShowingSaved
        sender.image = isShowingSaved ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        
        proxies = [
            FeedSectionProxy(feedType: isShowingSaved ? .saved : .all)
        ]
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}

extension MainViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {

    }

    func willDismissSearchController(_ searchController: UISearchController) {

    }
}

