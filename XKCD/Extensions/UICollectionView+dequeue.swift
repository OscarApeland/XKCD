//
//  UICollectionView+dequeue.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

/// Convenience extension to make the UICollectionView dequeue API typed and more compact
extension UICollectionView {

    func register<CellClass: UICollectionReusableView>(_ cellClass: CellClass.Type) {
        let cellId = String(describing: type(of: cellClass.classForCoder()))
        register(cellClass, forCellWithReuseIdentifier: cellId)
    }
    
    func dequeue<CellClass: UICollectionReusableView>(_ cellClass: CellClass.Type, for indexPath: IndexPath) -> CellClass {
        let cellId = String(describing: type(of: cellClass.classForCoder()))
        return dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CellClass
    }
}
