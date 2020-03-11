//
//  Fetcher.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit
import RealmSwift

struct ComicFetcher {
    
    // MARK: Nested models
    
    /// Model that matches the one returned from the XKCD API
    class ComicResultModel: Codable {
        let num: Int
        let title: String
        let alt: String
        let img: String
        
        let year: String
        let month: String
        let day: String
        
        var size = CGSize.zero
        
        enum CodingKeys: String, CodingKey {
            case num, title, alt, img, year, month, day
        }
    }

    static func getLatestComics(_ onCompletion: @escaping () -> Void) {
        let newestComicNumber = try! Realm()
            .objects(XKCD.self)
            .sorted(byKeyPath: "number", ascending: false)
            .first?.number
            ?? 2277
        
        getComic(number: newestComicNumber + 1) { didSucceed in
            didSucceed
                ? getLatestComics(onCompletion)
                : DispatchQueue.main.async(execute: onCompletion)
        }
    }
    
    static func getComic(number: Int, onCompletion: @escaping (_ isSuccess: Bool) -> Void = { _ in }) {
        guard case .none = try! Realm().object(ofType: XKCD.self, forPrimaryKey: String(number)) else {
            onCompletion(true)
            return
        }
        
        // Final step, store the API + Image result model in Realm
        let storeComic = { (comic: ComicResultModel) in
            let realm = try! Realm()
            realm.beginWrite()
            
            let xkcd = XKCD()
            xkcd.setProperties(from: comic)
            realm.add(xkcd, update: .all)
            
            do {
                try realm.commitWrite()
            } catch {
                onCompletion(false)
            }
            
            onCompletion(true)
        }
        
        // Second step, fetch the comic image to get the pixel size
        let fetchImage = { (comic: ComicResultModel) in
            URLSession.shared.dataTask(with: URL(string: comic.img)!) { data, _, error in
                guard let data = data, let image = UIImage(data: data) else {
                    onCompletion(false)
                    return
                }
                
                comic.size = image.size
                ImageStorage.save(image: image, forComic: number)
                
                storeComic(comic)
            }.resume()
        }
        
        // First step, fetch the data from the API
        let fetchData = {
            URLSession.shared.dataTask(
                with: URL(string: "https://xkcd.com/\(number)/info.0.json")!
            ) { data, _, error in
                guard let data = data, let comic = try? JSONDecoder().decode(ComicResultModel.self, from: data) else {
                    onCompletion(false)
                    return
                }
                
                fetchImage(comic)
            }.resume()
        }
        
        // Start the chain
        fetchData()
    }
    
    /// Searches for comic numbers that might be relevant
    static func getSuggestions(for query: String, onCompletion: @escaping ([Int]) -> Void) {
        let queryUrl = URL(string: "https://relevantxkcd.appspot.com/process?action=xkcd&query=\(query)")!
        URLSession.shared.dataTask(with: queryUrl) { (data, _, error) in
            guard let data = data, let result = String(data: data, encoding: .utf8) else {
                return
            }
            
            // Reduce the returned table-string-thing into an array of comic numbers
            let suggestedNumbers = result
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
                .dropFirst(2)
                .enumerated()
                .compactMap { $0 % 2 == 0 ? $1 : nil }
                .compactMap(Int.init)
            
            DispatchQueue.main.async {
                onCompletion(suggestedNumbers)
            }
        }.resume()
    }
}
