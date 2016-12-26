//
//  CollectionViewController.swift
//  PaginableTableView
//
//  Created by Julien Sarazin on 19/12/2016.
//  Copyright © 2016 Julien Sarazin. All rights reserved.
//

import UIKit

public protocol DGGridCollectionViewControllerDelegate: UICollectionViewDelegateFlowLayout {
	/**
	Must Returns the size of the loading Cell
	**/
	func loadingCellSize(collectionView: UICollectionView) -> CGSize

	/**
	Tells if the loading cell should be hidden if there is nothing more to load.
	**/
	func shouldHideLoadingCellWhenNothingToLoad() -> Bool

	/**
	Gives the height of the cell items, they will all have the same height except
	the loading cell.
	**/
	func heightForItemAtIndexPath(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat

	/**
	Gives the same width for each items
	**/
	func numberOfItemPerRow(_ collectionView: UICollectionView) -> CGFloat
}

public protocol DGGridCollectionViewControllerDataSource: UICollectionViewDataSource {
	/**
	Return the number of items that will be displayed before reloading
	**/
	func countPerPage(for section: Int) -> Int

	/**
	Request more data to the datasource, generally when the user reach the end of the collection
	**/
	func fetchData(from indexPath: IndexPath, with count: Int, completion: @escaping (Int) -> Void)

	/**
	Return the loading cell that will be displayed when the user will reach the end of the streal
	**/
	func controller(_ controller: DGGridCollectionViewController, loadingCellAt indexPath: IndexPath) -> UICollectionViewCell
}

open class DGGridCollectionViewController: UICollectionViewController {
	public fileprivate(set) var loading  = true
	public fileprivate(set) var fetching = false

	fileprivate var collectionViewDelegateProxy: CollectionViewDelegateProxy
	fileprivate var collectionViewDataSourceProxy: CollectionViewDataSourceProxy

	fileprivate weak var _delegate: DGGridCollectionViewControllerDelegate?
	fileprivate weak var _dataSource: DGGridCollectionViewControllerDataSource?

	private var _paginationEnabled: Bool = false
	public var paginationEnabled: Bool {
		get {
			return self._paginationEnabled
		}
		set {
			self._paginationEnabled = newValue
			self.collectionView?.reloadData()
		}
	}

	public weak var delegate: DGGridCollectionViewControllerDelegate? {
		get {
			return self._delegate
		}
		set {
			self._delegate = newValue
			self.collectionView?.delegate	= self.collectionViewDelegateProxy
		}
	}

	public weak var dataSource: DGGridCollectionViewControllerDataSource? {
		get {
			return self._dataSource
		}
		set {
			self._dataSource = newValue
			self.collectionView?.dataSource = self.collectionViewDataSourceProxy
		}
	}

	convenience public init() {
		self.init(nibName: nil, bundle:nil)
	}

	override public init(nibName: String?, bundle: Bundle?) {
		collectionViewDelegateProxy		= CollectionViewDelegateProxy()
		collectionViewDataSourceProxy	= CollectionViewDataSourceProxy()
		super.init(nibName: nibName, bundle: bundle)
		collectionViewDelegateProxy.collectionController = self
		collectionViewDataSourceProxy.collectionController = self
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open override func loadView() {
		guard self.nibName == nil else {
			return super.loadView()
		}

		self.view = UIView()
		self.view.clipsToBounds = true
		self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		self.view.autoresizesSubviews = true

		self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
		self.collectionView?.backgroundColor = .white
		self.collectionView?.clipsToBounds = true
	}

	public func register(_ nib: UINib, forCellWithReuseIdentifier identifier: String) {
		self.collectionView?.register(nib, forCellWithReuseIdentifier: identifier)
	}

	public func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool) {
		self.collectionView?.setCollectionViewLayout(layout, animated: animated)
	}
}

private class CollectionViewDataSourceProxy: NSObject, UICollectionViewDataSource {
	weak var collectionController: DGGridCollectionViewController!

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let count =  self.collectionController.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0

		guard self.collectionController.paginationEnabled else {
			return count
		}

		if self.collectionController.loading == false && self.collectionController.delegate!.shouldHideLoadingCellWhenNothingToLoad() {
			return count
		}

		return count + 1 // needed to have the loading cell at the end of the rows
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let count = self.collectionController.dataSource?.collectionView(collectionView, numberOfItemsInSection: indexPath.section) ?? 0

		guard indexPath.row < count else {
			return self.collectionController.dataSource!.controller(self.collectionController, loadingCellAt: indexPath)
		}

		return self.collectionController.dataSource!.collectionView(collectionView, cellForItemAt: indexPath)
	}

	fileprivate override func responds(to aSelector: Selector!) -> Bool {
		if super.responds(to: aSelector) {
			return true
		}

		if let dataSource = self.collectionController.dataSource,
			dataSource.responds(to: aSelector) {
			return true
		}

		return self.collectionController.responds(to: aSelector)
	}

	fileprivate override func forwardingTarget(for aSelector: Selector!) -> Any? {
		if let dataSource = self.collectionController.dataSource,
			dataSource.responds(to: aSelector) {
			return dataSource
		}

		if self.collectionController.responds(to: aSelector) {
			return self.collectionController
		}

		return nil
	}
}

private class CollectionViewDelegateProxy: NSObject, UICollectionViewDelegateFlowLayout {
	weak var collectionController: DGGridCollectionViewController!

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let count =  self.collectionController.dataSource?.collectionView(collectionView, numberOfItemsInSection: indexPath.section) ?? 0
		if indexPath.row == count {
			return self.collectionController.delegate!.loadingCellSize(collectionView: collectionView)
		}

		guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			fatalError("unhandlded layout")
		}

		let itemPerRow = self.collectionController.delegate!.numberOfItemPerRow(collectionView)
		var sectionInset = UIEdgeInsets()
		var minimumInteritemSpacing: CGFloat = 0.0

		if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
			sectionInset = delegate.collectionView?(collectionView, layout: layout, insetForSectionAt: indexPath.section) ?? UIEdgeInsets()
			minimumInteritemSpacing = delegate.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: indexPath.section) ?? 0
		}

		let baseWidth = (collectionView.frame.width - sectionInset.left - sectionInset.right - (minimumInteritemSpacing * itemPerRow))

		let width  =  baseWidth / itemPerRow
		let height = self.collectionController.delegate!.heightForItemAtIndexPath(collectionView, indexPath: indexPath)
		return CGSize(width: width, height: height)
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.collectionController.delegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
		let count =  self.collectionController.dataSource?.collectionView(collectionView, numberOfItemsInSection: indexPath.section) ?? 0

		guard indexPath.row == count else {
			return
		}

		let countPerPage = self.collectionController.dataSource!.countPerPage(for: indexPath.section)

		guard !self.collectionController.fetching else {
			return
		}

		self.collectionController.fetching = true
		self.collectionController.dataSource?.fetchData(from: indexPath, with: countPerPage) { (elementsCount) in
			self.collectionController.loading = (elementsCount > 0 && elementsCount >= countPerPage)
			self.collectionController.fetching = false
			self.collectionController.collectionView?.reloadData()
		}
	}

	override func responds(to aSelector: Selector!) -> Bool {
		if super.responds(to: aSelector) {
			return true
		}
		if let delegate = self.collectionController.delegate,
			delegate.responds(to: aSelector) {
			return true
		}

		return self.collectionController.responds(to: aSelector)
	}

	override func forwardingTarget(for aSelector: Selector!) -> Any? {
		if let delegate = self.collectionController.delegate,
			delegate.responds(to: aSelector) {
			return delegate
		}

		if self.collectionController.responds(to: aSelector) {
			return self.collectionController
		}
		
		return nil
	}
}
