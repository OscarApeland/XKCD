//
//  UICollectionView+RealmReloading.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    /// performBatchUpdates exploding indexPaths from a Realm.List observation change set
    func batchUpdate<CollectionType>(section: Int, with changes: (_: CollectionType, deletions: [Int], insertions: [Int], modifications: [Int])) {
        let indexPath = {
            IndexPath(item: $0, section: section)
        }
        
        let (insertions, deletions, modifications) = (
             changes.insertions.map(indexPath),
             changes.deletions.map(indexPath),
             changes.modifications.map(indexPath)
        )
        
        performBatchUpdates({
            insertItems(at: insertions)
            deleteItems(at: deletions)
            reloadItems(at: modifications)
        })
    }
}
