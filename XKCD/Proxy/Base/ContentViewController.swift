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
    
    lazy var layout = ContentFlowLayout()
    
    lazy var collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
    
    
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
    
    
    // MARK: Cell Resizing
    
    private lazy var currentSize = view.bounds.size
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard view.bounds.size != currentSize else {
            return
        }
        
        currentSize = view.bounds.size
        collectionView.setCollectionViewLayout(ContentFlowLayout(), animated: true)
    }
    
    
    // MARK: Convenience
    
    /// Safely fetches the proxy at the requested index, if any. Helps avoid random UICollectionView state issues.
    func proxy(at index: Int) -> ContentProxy? {
        proxies.indices.contains(index) ? proxies[index] : nil
    }
}

extension ContentViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return proxies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return proxy(at: section)?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return proxy(at: indexPath.section)!.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return proxy(at: indexPath.section)?.collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) ?? UICollectionReusableView()
    }
}

extension ContentViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        proxies.forEach {
            $0.scrollViewDidScroll?(scrollView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        proxy(at: indexPath.section)?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        proxy(at: indexPath.section)?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        proxy(at: indexPath.section)?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        proxy(at: indexPath.section)?.collectionView?(collectionView, didDeselectItemAt: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        proxy(at: section)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        proxy(at: section)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        proxy(at: section)?.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ?? .zero
    }
}
