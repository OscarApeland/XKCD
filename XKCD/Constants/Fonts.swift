//
//  Fonts.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

extension UIFont {
    
    static let title = UIFont.systemFont(ofSize: 14.0, weight: .bold)
    
    static let caption = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    
    static let date = UIFont.systemFont(ofSize: 12.0, weight: .regular)
}

extension UIFont {
    var labelHeight: CGFloat {
        return lineHeight.rounded(.up)
    }
}
