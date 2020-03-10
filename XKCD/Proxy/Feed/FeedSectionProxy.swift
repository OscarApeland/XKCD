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

    let comics = try! Realm()
        .objects(XKCD.self)
        .sorted(byKeyPath: "number", ascending: false)
    
    
    // MARK: Proxy
    
    weak var collectionView: UICollectionView?
    weak var parent: ContentViewController?
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
        self.parent = parent
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

    
    // MARK: Context menu
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let comic = comics[indexPath.item]

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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = collectionView.bounds.width < 500
            ? .sidePadding
            : (collectionView.bounds.width - 500) / 2

        return UIEdgeInsets(top: 0.0, left: margin, bottom: .sectionSpacing, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let comic = comics[indexPath.item]
        
        let contentWidth = min(500.0, collectionView.bounds.width - .sidePadding * 2)
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
