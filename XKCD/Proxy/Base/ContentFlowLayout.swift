//
//  ContentFlowLayout.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

class ContentFlowLayout: UICollectionViewFlowLayout {
    
    static let wideTreshold = CGFloat(500.0)
    
    var isWide: Bool {
        (collectionView?.bounds.width ?? ContentFlowLayout.wideTreshold - 1) > ContentFlowLayout.wideTreshold
    }
}

