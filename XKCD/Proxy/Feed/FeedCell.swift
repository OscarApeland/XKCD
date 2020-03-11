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
            
            dateLabel.text = Date().timeIntervalSince(comic.date) > 60 * 60 * 24 * 7
                ? DateFormatter.localizedString(from: comic.date, dateStyle: .medium, timeStyle: .none)
                : RelativeDateTimeFormatter().localizedString(for: comic.date, relativeTo: Date())
        }
    }
    
    
    // MARK: Outlets
        
    let imageView = UIImageView()
    
    let titleLabel = UILabel()
    
    let captionLabel = UILabel()
    
    let dateLabel = UILabel()

    
    lazy var imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, constant: 1.0)
    
    
    lazy var zoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
    
    
    // MARK: Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(zoomGesture)

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
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            captionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .viewSpacing),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: .viewSpacing),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5.0),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    required init?(coder _: NSCoder) {
        return nil
    }
    
    
    // MARK: Zoom
    
    weak var zoomImageView: UIImageView?
    weak var zoomBackgroundView: UIView?
    private var zoomSourcePoint: CGPoint?
    private var zoomSourceFrame: CGRect?
    
    @objc private func pinched(with gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIImpactFeedbackGenerator().impactOccurred(intensity: 0.2)
            
            zoomSourceFrame = convert(imageView.frame, to: window)
            zoomSourcePoint = gesture.location(in: window)
            
            window?.addSubview({
                $0.frame = window!.bounds
                $0.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                $0.alpha = 0.0

                zoomBackgroundView = $0
                return $0
            }(UIView()))
            
            window?.addSubview({
                $0.frame = zoomSourceFrame!
                $0.image = imageView.image
                $0.contentMode = .scaleAspectFill
                $0.clipsToBounds = true
                $0.layer.cornerRadius = layer.cornerRadius
                
                zoomImageView = $0
                return $0
            }(UIImageView()))
            
            imageView.isHidden = true
            
        case .changed:
            let scale = max(1, gesture.scale)

            zoomBackgroundView?.alpha = scale - 1
            zoomImageView?.frame.size = CGSize(width: zoomSourceFrame!.width * scale,
                                               height: zoomSourceFrame!.height * scale)
            zoomImageView?.center = CGPoint(x: zoomSourceFrame!.midX - (zoomSourcePoint!.x - gesture.location(in: window).x),
                                            y: zoomSourceFrame!.midY - (zoomSourcePoint!.y - gesture.location(in: window).y))
            
            if let imageView = zoomImageView, imageView.layer.cornerRadius > 0 {
                imageView.layer.cornerRadius = zoomSourceFrame!.height * scale / 2
            }
            
        case .ended, .failed, .cancelled:
            UIView.animate(withDuration: 0.2, animations: {
                self.zoomImageView?.frame = self.zoomSourceFrame!
                self.zoomBackgroundView?.alpha = 0.0
                if let imageView = self.zoomImageView, imageView.layer.cornerRadius > 0 {
                    imageView.layer.cornerRadius = self.zoomSourceFrame!.height / 2
                }
            }) { _ in
                self.imageView.isHidden = false
                self.zoomImageView?.removeFromSuperview()
                self.zoomBackgroundView?.removeFromSuperview()
                
                UIImpactFeedbackGenerator().impactOccurred(intensity: 0.2)
            }
            
        default:
            break
        }
    }
}
