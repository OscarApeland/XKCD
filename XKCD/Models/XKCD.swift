//
//  XKCD.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class XKCD: Object {
    
    // Realm doesn't provide normal inits, so empty placeholders guaranteed to be overwritten is easiest.
    // Realm also requires all properties to be @objc dynamic
    
    dynamic var number = 0
    dynamic var title = ""
    dynamic var caption = ""
    dynamic var imageUrl = ""
    
    dynamic var year = 0
    dynamic var month = 0
    dynamic var day = 0
    
    dynamic var isSaved = false
}
