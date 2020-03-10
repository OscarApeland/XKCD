//
//  FeedSectionProxy.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit
import RealmSwift

class FeedSectionProxy: ContentProxy {

    let comics = try! Realm()
        .objects(XKCD.self)
        .sorted(byKeyPath: "number", ascending: false)
    
    
    // MARK: Proxy
    
    weak var collectionView: UICollectionView?
    weak var presentingViewController: ContentViewController?
    var contentSectionIndex = 0
    
    
    // MARK: Observations
    
    private var token: NotificationToken?

    
    // MARK: Inits
   
    override init() {
        super.init()
        
        token = comics.observe { [weak self] change in
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
    
    func didMove(to section: Int, in collectionView: UICollectionView, with parent: ContentViewController) {
        self.collectionView = collectionView
        self.presentingViewController = parent
        self.contentSectionIndex = section
        
        collectionView.register(FeedCell.self)
    }
    
    deinit {
        token?.invalidate()
    }
    
    
    // MARK: DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FeedCell.self, for: indexPath)
        
        cell.comic = comics[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == comics.count - 5 {
            ComicFetcher.fetchMoreComics()
        }
    }
    
    
    // MARK: Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .sectionSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: .sidePadding, bottom: .sectionSpacing, right: .sidePadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let comic = comics[indexPath.item]
        
        let contentWidth = (collectionViewLayout as! ContentFlowLayout).isWide
            ? (collectionView.bounds.width - .sidePadding * 2) / 2
            : collectionView.bounds.width - .sidePadding * 2
        
        let imageHeight = contentWidth * CGFloat(comic.imageHeight / comic.imageWidth)
        
        let titleHeight = comic.title.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                                                   options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                   attributes: [.font: UIFont.title],
                                                   context: nil).size.height
        
        let captionHeight = comic.caption.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                                                       options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                       attributes: [.font: UIFont.caption],
                                                       context: nil).size.height
        
        let totalHeight = 0
            + imageHeight + .itemSpacing
            + titleHeight + .viewSpacing
            + captionHeight + .viewSpacing
            + UIFont.date.labelHeight
    
        return CGSize(width: collectionView.bounds.width - .sidePadding * 2, height: totalHeight)
    }
}
