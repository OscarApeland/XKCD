//
//  Spacing.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

extension CGFloat {
 
    /// Horizontal whitespace around everything (26 or 30)
    static let sidePadding = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(20) : CGFloat(16)

    /// Spacing between different types of content (40)
    static let sectionSpacing = CGFloat(40)
    
    /// Spacing between items in a section (16)
    static let itemSpacing = CGFloat(16)
    
    /// Spacing between views in the same group (8)
    static let viewSpacing = CGFloat(8)
}
