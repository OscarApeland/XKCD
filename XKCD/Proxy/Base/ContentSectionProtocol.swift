//
//  ContentSectionProtocol.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

protocol Proxyable: UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout {
    func didMove(to section: Int, in collectionView: UICollectionView, with parent: ContentViewController)
}

typealias ContentProxy = NSObject & Proxyable
