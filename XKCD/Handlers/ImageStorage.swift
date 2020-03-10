//
//  ImageStorage.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

struct ImageStorage {
    
    static var directory: URL = {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = documentDirectory.appendingPathComponent("comics", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        
        return directory
    }()
    
    static func save(image: UIImage, forComic number: Int) {
        let localUrl = directory.appendingPathComponent("\(number).png")
        try! image.pngData()!.write(to: localUrl)
    }
    
    static func getImage(forComic number: Int) -> UIImage {
        UIImage(contentsOfFile: directory.appendingPathComponent("\(number).png").path)!
    }
}
