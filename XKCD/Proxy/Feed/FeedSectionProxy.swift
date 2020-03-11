//
//  FeedSectionProxy.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

class FeedSectionProxy: ContentProxy {
    
    
    // MARK: Proxy
    
    weak var collectionView: UICollectionView?
    weak var parent: ContentViewController?
    var contentSectionIndex = 0
    
    
    // MARK: Observations
    
    private var token: NotificationToken?

    
    // MARK: Inits
    
    enum FeedType {
        case all, saved, search(String)
    }
   
    let feedType: FeedType
    
    init(feedType: FeedType) {
        self.feedType = feedType
        
        super.init()
        
        loadResults(for: feedType)
    }
    
    func didMove(to section: Int, in collectionView: UICollectionView, with parent: ContentViewController) {
        self.collectionView = collectionView
        self.parent = parent
        self.contentSectionIndex = section
        
        collectionView.register(FeedCell.self)
    }
    
    deinit {
        token?.invalidate()
    }
    
    
    // MARK: Feed loading
    
    private var comics: Results<XKCD>?
    
    private var searchResults = [Int]()
    
    private func xkcd(at index: Int) -> XKCD {
        if case .search = feedType {
            return comics!.sorted {
                searchResults.firstIndex(of: $0.number)! > searchResults.firstIndex(of: $1.number)!
            }[index]
        } else {
            return comics![index]
        }
    }
        
    
    private func loadResults(for type: FeedType) {
        switch type {
        case .all:
            comics = try! Realm()
                .objects(XKCD.self)
                .sorted(byKeyPath: "number", ascending: false)
            observeResults()
            
        case .saved:
            comics = try! Realm()
                .objects(XKCD.self)
                .filter("isSaved == true")
                .sorted(byKeyPath: "number", ascending: false)
            observeResults()
            
        case .search(let query):
            if let queryNumber = Int(query), 0 ... 9999 ~= queryNumber {
                ComicFetcher.getComic(number: queryNumber)
                comics = try! Realm()
                    .objects(XKCD.self)
                    .filter("number == %@", queryNumber)
                observeResults()
            } else {
                ComicFetcher.fetchSuggestions(for: query) { [weak self] suggestedNumbers in
                    guard let welf = self, !suggestedNumbers.isEmpty else {
                        return
                    }
                    
                    welf.collectionView?.refreshControl?.beginRefreshing()
                                    
                    let dispatchGroup = DispatchGroup()
                    suggestedNumbers.forEach { suggestedNumber in
                        dispatchGroup.enter()
                        ComicFetcher.getComic(number: suggestedNumber) { _ in
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        welf.searchResults = suggestedNumbers
                        welf.comics = try! Realm()
                            .objects(XKCD.self)
                            .filter("number IN %@", suggestedNumbers)
                        welf.collectionView?.reloadSections(IndexSet(integer: welf.contentSectionIndex))
                        welf.collectionView?.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
    
    private func observeResults() {
        token = comics!.observe { [weak self] change in
            guard let welf = self else { return }
            
            switch change {
            case .initial:
                welf.collectionView?.reloadSections(IndexSet(integer: welf.contentSectionIndex))
                
            case .update(let changes):
                welf.collectionView?.batchUpdate(section: welf.contentSectionIndex, with: changes)
                
            case .error(let error):
                print(error)
            }
        }
    }
    
    
    // MARK: Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        comics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FeedCell.self, for: indexPath)
        
        cell.comic = xkcd(at: indexPath.item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let comic = xkcd(at: indexPath.item)
        if case .all = feedType, comic.number - 1 > 0 {
            ComicFetcher.getComic(number: comic.number - 1)
        }
    }

    
    // MARK: Context menu
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let comic = xkcd(at: indexPath.item)

        let save = UIAction(
            title: comic.isSaved ? NSLocalizedString("Unsave", comment: "") : NSLocalizedString("Save", comment: ""),
            image: comic.isSaved ? UIImage(systemName: "heart.slash") : UIImage(systemName: "heart"))
        { _ in
            try! Realm().write {
                comic.isSaved = !comic.isSaved
            }
        }
        
        let explain = UIAction(
            title: NSLocalizedString("Explain", comment: ""),
            image: UIImage(systemName: "questionmark.circle"))
        { _ in
            let explanationUrl = URL(string: "https://www.explainxkcd.com/wiki/index.php/\(comic.number)")!
            let viewController = SFSafariViewController(url: explanationUrl)
            viewController.preferredControlTintColor = .label
            
            self.parent?.present(viewController, animated: true)
        }
        
        let share = UIAction(
            title: NSLocalizedString("Share", comment: ""),
            image: UIImage(systemName: "square.and.arrow.up"))
        { _ in
            let activityViewController = UIActivityViewController(
                activityItems: [URL(string: "https://xkcd.com/\(comic.number)")!],
                applicationActivities: nil
            )
            
            activityViewController.popoverPresentationController?.sourceView = collectionView.cellForItem(at: indexPath)
            self.parent?.present(activityViewController, animated: true)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [save, explain, share])
        }
    }
    
    
    // MARK: Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .sectionSpacing
    }
    
    var layoutWidth: CGFloat {
        collectionView!.frame.width
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = layoutWidth < 500 + .sidePadding * 2
            ? .sidePadding
            : (collectionView.bounds.width - 500) / 2

        return UIEdgeInsets(top: 0.0, left: margin, bottom: .sectionSpacing, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let comic = xkcd(at: indexPath.item)
                
        let contentWidth = layoutWidth < 500 + .sidePadding * 2
            ? layoutWidth - .sidePadding * 2
            : 500.0
        
        let imageHeight = contentWidth * CGFloat(comic.imageHeight / comic.imageWidth)
        
        let titleHeight = comic.title.boundingRect(with: CGSize(width: contentWidth - 5.0, height: .greatestFiniteMagnitude),
                                                  options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                  attributes: [.font: UIFont.title],
                                                  context: nil).size.height
        
        let captionHeight = comic.caption.boundingRect(with: CGSize(width: contentWidth - 5.0, height: .greatestFiniteMagnitude),
                                                      options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                      attributes: [.font: UIFont.caption],
                                                      context: nil).size.height
        
        let totalHeight = 0
            + imageHeight + .itemSpacing
            + titleHeight + .viewSpacing
            + captionHeight + .viewSpacing
            + UIFont.date.labelHeight
    
        return CGSize(width: contentWidth, height: totalHeight)
    }
}
