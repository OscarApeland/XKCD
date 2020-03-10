//
//  FeedCell.swift
//  XKCD
//
//  Created by Oscar Apeland on 10/03/2020.
//  Copyright © 2020 Oscar Apeland. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell {
    
    var comic: XKCD? {
        didSet {
            guard let comic = comic else { return }
            
            imageHeightConstraint.isActive = false
            imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(comic.imageHeight / comic.imageWidth))
            imageHeightConstraint.isActive = true
            
            imageView.image = ImageStorage.getImage(forComic: comic.number)
            titleLabel.text = comic.title
            captionLabel.text = comic.caption
            dateLabel.text = RelativeDateTimeFormatter().localizedString(for: comic.date, relativeTo: Date())
            
            saveButton.isSelected = comic.isSaved
        }
    }
    
    
    // MARK: Outlets
    
    let imageView = UIImageView()
    
    let titleLabel = UILabel()
    
    let captionLabel = UILabel()
    
    let dateLabel = UILabel()
    
    let saveButton = UIButton()
    
    let explainButton = UIButton()
    
    let shareButton = UIButton()
    
    lazy var imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, constant: 1.0)
    
    
    // MARK: Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .title
        titleLabel.textColor = .label
        
        captionLabel.numberOfLines = 0
        captionLabel.font = .caption
        captionLabel.textColor = .label
        
        dateLabel.font = .date
        dateLabel.textColor = .secondaryLabel
        
        [imageView, titleLabel, captionLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageHeightConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: .itemSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            captionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .viewSpacing),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: .viewSpacing),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    required init?(coder _: NSCoder) {
        return nil
    }
}
