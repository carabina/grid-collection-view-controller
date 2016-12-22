//
//  AlignLeftLayout.swift
//  PaginableTableView
//
//  Created by Julien Sarazin on 19/12/2016.
//  Copyright © 2016 Julien Sarazin. All rights reserved.
//

import UIKit

extension UICollectionViewLayoutAttributes {
	func leftAlignFrame(from sectionInset: UIEdgeInsets) {
		var frame: CGRect = self.frame
		frame.origin.x = sectionInset.left
		self.frame = frame
	}
}

class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
	/**
	Uses the same layout processing than layoutAttributesForItemAtIndexPath:
	Just copying each properties to the generated layout attributes from the super class "FlowLayout"
	**/
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let originalAttributes = super.layoutAttributesForElements(in: rect)!
		var updatedAttributes = Array(originalAttributes)

		originalAttributes.forEach({ (attributes) in
			guard attributes.representedElementKind == nil else {
				return
			}

			let index = updatedAttributes.index(of: attributes)!
			updatedAttributes[index] = self.layoutAttributesForItem(at: attributes.indexPath)!
		})

		return updatedAttributes
	}

	/**
	Position the items to left even if the row is not completely filled.
	Take into account the interspacing and the section insest.
	**/
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard let currentItemAttributes: UICollectionViewLayoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy(with: nil) as? UICollectionViewLayoutAttributes else {
			fatalError("Unhandled error")
		}

		let sectionInset = self.evaluatedSectionInsetForItem(at: indexPath.section)

		let isFirstItemInSection = indexPath.item == 0

		guard !isFirstItemInSection else {
			currentItemAttributes .leftAlignFrame(from: sectionInset)
			return currentItemAttributes
		}

		let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
		let previousFrame = self.layoutAttributesForItem(at: previousIndexPath)!.frame
		let previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width
		var currentFrame = currentItemAttributes.frame

		// if the current frame is under the previous it means the current is the first in the row
		let isFirstItemInRow: Bool = previousFrame.origin.y < currentFrame.origin.y

		guard !isFirstItemInRow else {
			currentItemAttributes.leftAlignFrame(from: sectionInset)
			return currentItemAttributes
		}

		// Here we need to put the currentFrame next to the previous frame
		currentFrame.origin.x = previousFrameRightPoint + self.evaluatedMinimumInteritemSpacingForSection(at: indexPath.section)
		currentItemAttributes.frame = currentFrame
		return currentItemAttributes
	}

	func evaluatedSectionInsetForItem(at index: Int) -> UIEdgeInsets {
		if let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
			if let insets = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: index) {
				return insets
			}
		}

		return self.sectionInset
	}

	func evaluatedMinimumInteritemSpacingForSection(at index: Int) -> CGFloat {
		if let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
			if let spacing = delegate.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: index) {
				return spacing
			}
		}

		return self.minimumLineSpacing
	}
}
