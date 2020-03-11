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
    
    // MARK: External entries

    /// Fetch comics up until the most recently posted one, and backwards until the store contains at least 15 comics.
    static func refreshComics(onCompletion: @escaping () -> Void) {
        
        var results = [ComicResultModel]()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchUpToNewest() { freshComics in
            results.append(contentsOf: results)
            dispatchGroup.leave()
        }
        
        
        if try! Realm().objects(XKCD.self).count < 15 {
            dispatchGroup.enter()
            fetchNextPage { oldComics in
                results.append(contentsOf: oldComics)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            store(comics: results)
            onCompletion()
        }
    }
    
    /// Fetch another page of comics
    static func fetchMoreComics() {
        fetchNextPage { moreComics in
            store(comics: moreComics)
        }
    }
    
    
    // MARK: Nested models
    
    /// Model that matches the one returned from the XKCD API
    private class ComicResultModel: Codable {
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
    
    private enum ComicAPIError: String, Error {
        case notFound, networkIssue, imageMissing
    }
    
    
    // MARK: Storage
    
    /// Converts the temporary API model into a Realm object and adds it to the database.
    private static func store(comics: [ComicResultModel]) {
        let realm = try! Realm()
        try! realm.write {
            comics.forEach { comic in
                let xkcd = XKCD()
                xkcd.number = comic.num
                xkcd.title = comic.title
                xkcd.caption = comic.alt
                xkcd.imageWidth = Double(comic.size.width)
                xkcd.imageHeight = Double(comic.size.height)
                xkcd.date = {
                    var components = DateComponents()
                    components.setValue(Int(comic.year), for: .year)
                    components.setValue(Int(comic.month), for: .month)
                    components.setValue(Int(comic.day), for: .day)
                    return Calendar.current.date(from: components)!
                }()

                realm.add(xkcd, update: .all)
            }
        }
    }
    
    
    // MARK: Fetching logic

    /// Recurses upwards from the latest comic until no more recent comics can be found, then returns all the comics after the initial number.
    private static func fetchUpToNewest(from number: Int = mostRecentComicNumber() + 1, comics: [ComicResultModel] = [], onCompletion: @escaping ([ComicResultModel]) -> Void) {
        fetchComic(number: number) { result in
            switch result {
            case .success(let comic):
                fetchUpToNewest(from: number + 1, comics: comics + [comic], onCompletion: onCompletion)
                
            case .failure(let error):
                print(error)
                onCompletion(comics)
            }
        }
    }
    
    /// Fetches 15 comics older than the oldest comic
    private static func fetchNextPage(onCompletion: @escaping ([ComicResultModel]) -> Void) {
        guard leastRecentComicNumber() > 0 else {
            onCompletion([])
            return
        }
        
        let nextPageNumbers = Array(max(0, leastRecentComicNumber() - 15) ... leastRecentComicNumber())
        fetchComics(numbers: nextPageNumbers, onCompletion: onCompletion)
    }
    
    /// Fetches all the comics in the numbers array
    private static func fetchComics(numbers: [Int], onCompletion: @escaping ([ComicResultModel]) -> Void) {
        var results: [ComicResultModel] = []
        
        let dispatchGroup = DispatchGroup()
        
        numbers.forEach { number in
            dispatchGroup.enter()
            
            fetchComic(number: number) { result in
                switch result {
                case .success(let model):
                    results.append(model)
                    
                case .failure(let error):
                    print(error)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            onCompletion(results)
        }
    }
    
    
    // MARK: API Calls
    
    /// Fetch a single comic from the XKCD API
    /// Also fetches the image and stores it to disk, so presentation is easier
    private static func fetchComic(number: Int, onCompletion: @escaping (Result<ComicResultModel, ComicAPIError>) -> Void) {
        let url = URL(string: "https://xkcd.com/\(number)/info.0.json")!
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data else {
                onCompletion(.failure(.networkIssue))
                return
            }
            
            let comic: ComicResultModel
            do {
                comic = try JSONDecoder().decode(ComicResultModel.self, from: data)
            } catch {
                print(error)
                onCompletion(.failure(.notFound))
                return
            }
            
            fetchImage(at: URL(string: comic.img)!, forComic: comic.num) { result in
                switch result {
                case .success(let imageSize):
                    comic.size = imageSize
                    onCompletion(.success(comic))
                    
                case .failure(let error):
                    print(error)
                    onCompletion(.failure(.imageMissing))
                }
            }
        }.resume()
    }
    
    /// Grabs the image, stores it to disk, and returns its dimensions
    private static func fetchImage(at imageUrl: URL, forComic number: Int, onCompletion: @escaping (Result<CGSize, ComicAPIError>) -> Void) {
        URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
            guard let data = data, let image = UIImage(data: data) else {
                onCompletion(.failure(.notFound))
                return
            }
            
            ImageStorage.save(image: image, forComic: number)
            onCompletion(.success(image.size))
        }.resume()
    }
    
    
    // MARK: Internal convenience
    
    private static func mostRecentComicNumber() -> Int {
        try! Realm()
            .objects(XKCD.self)
            .sorted(byKeyPath: "number", ascending: false)
            .first?.number
            ?? 2278
    }
    
    private static func leastRecentComicNumber() -> Int {
        try! Realm()
            .objects(XKCD.self)
            .sorted(byKeyPath: "number", ascending: true)
            .first?.number
            ?? 2278
    }
    
}
