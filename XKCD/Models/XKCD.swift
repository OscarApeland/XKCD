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
    dynamic var id = ""
    
    dynamic var number = 0 {
        didSet {
            id = String(number)
        }
    }
    
    dynamic var title = ""
    dynamic var caption = ""
        
    dynamic var date = Date()
    
    dynamic var imageHeight = 0.0
    dynamic var imageWidth = 0.0
    
    /// Flag indicating if the user has saved this comic
    dynamic var isSaved = false
    dynamic var savedAt = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    
    // MARK: Convenience
    
    func setProperties(from comic: ComicFetcher.ComicResultModel) {
        number = comic.num
        title = comic.title
        caption = comic.alt
        imageWidth = Double(comic.size.width)
        imageHeight = Double(comic.size.height)
        date = {
            var components = DateComponents()
            components.setValue(Int(comic.year), for: .year)
            components.setValue(Int(comic.month), for: .month)
            components.setValue(Int(comic.day), for: .day)
            return Calendar.current.date(from: components)!
        }()
    }
}
