//
//  ProxyViewController.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

/// UICollectionViewController replica that delegates all source calls to the appropriate section
class ContentViewController: UIViewController {
    
    var proxies: [ContentProxy] = [] {
        didSet {
            proxies.enumerated().forEach {
                $0.element.didMove(to: $0.offset, in: collectionView, with: self)
            }
        }
    }
    
    
    // MARK: Outlets
        
    lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        collectionView.contentInset = .init(top: .sectionSpacing, left: .zero, bottom: .sectionSpacing, right: .zero)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(collectionView)
    }
    
    
    // MARK: Adaptive Layout
    
    private lazy var currentBounds = view.bounds
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard view.bounds != currentBounds else {
            return
        }
        
        currentBounds = view.bounds
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // MARK: Convenience
    
    func proxy(at index: Int) -> ContentProxy? {
        proxies.indices.contains(index) ? proxies[index] : nil
    }
}

extension ContentViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        proxies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        proxy(at: section)?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        proxy(at: indexPath.section)!.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

extension ContentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        proxy(at: indexPath.section)?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        proxy(at: indexPath.section)?.collectionView?(collectionView, contextMenuConfigurationForItemAt: indexPath, point: point)
    }
}

extension ContentViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        proxy(at: indexPath.section)?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        proxy(at: section)?.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) ?? 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        proxy(at: section)?.collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) ?? 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        proxy(at: section)?.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ?? .zero
    }
}
