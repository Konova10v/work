//
//  ImageScrollView2.swift
//  Scroll
//
//  Created by Imanou on 13/01/2018.
//  Copyright © 2018 Imanou. All rights reserved.
//

import UIKit
import SDWebImage

final class ImageScrollView: UIScrollView {
    
	private var imageView = UIImageView()
	private var imageViewBottomConstraint: NSLayoutConstraint?;
    private var imageViewLeadingConstraint: NSLayoutConstraint?;
    private var imageViewTopConstraint: NSLayoutConstraint?;
    private var imageViewTrailingConstraint: NSLayoutConstraint?;
    
  
    required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
		
		self.contentInsetAdjustmentBehavior = .never
		self.showsVerticalScrollIndicator = false
		self.showsHorizontalScrollIndicator = false
		self.alwaysBounceHorizontal = false
		self.alwaysBounceVertical = false
		
		self.delegate = self
    }
    
	func setImageView (imgView: UIImageView) {
		self.imageView = imgView;
		imageView.translatesAutoresizingMaskIntoConstraints = false
		if let constraint = imageViewLeadingConstraint {
			NSLayoutConstraint.deactivate([constraint])
		}
		if let constraint = imageViewTrailingConstraint {
			NSLayoutConstraint.deactivate([constraint])
		}
		if let constraint = imageViewTopConstraint {
			NSLayoutConstraint.deactivate([constraint])
		}
		if let constraint = imageViewBottomConstraint {
			NSLayoutConstraint.deactivate([constraint])
		}
		imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
		imageViewTrailingConstraint = imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
		imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
		imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
		NSLayoutConstraint.activate([imageViewLeadingConstraint!, imageViewTrailingConstraint!, imageViewTopConstraint!, imageViewBottomConstraint!])
	
		
		self.imageView.sizeToFit()
		self.scrollViewDidZoom(self)
		
	}
    // MARK: - Helper methods
    
    func setZoomScale() {
        let widthScale = frame.size.width / imageView.bounds.width
        let heightScale = frame.size.height / imageView.bounds.height
        var minScale = min(widthScale, heightScale)
		if minScale > 1.0 {
			minScale = 1.0
		}
        minimumZoomScale = minScale
		maximumZoomScale = 3
        zoomScale = minScale
		scrollViewDidZoom(self)
    }
        
}

extension ImageScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
		layoutIfNeeded()
        let yOffset = max(0, (bounds.size.height - imageView.frame.height) / 2)
        imageViewTopConstraint?.constant = yOffset
        imageViewBottomConstraint?.constant = yOffset
        
        let xOffset = max(0, (bounds.size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint?.constant = xOffset
        imageViewTrailingConstraint?.constant = xOffset
//		print("!!! "+bounds.size.height.description + " " + imageView.frame.height.description + " => " + yOffset.description);
        layoutIfNeeded()
    }
    
}
