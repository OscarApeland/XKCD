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
        
        // Discard modification reloading because they are not relevant in this app
        
        performBatchUpdates({
            insertItems(at: changes.insertions.map(indexPath))
            deleteItems(at: changes.deletions.map(indexPath))
        })
    }
}
