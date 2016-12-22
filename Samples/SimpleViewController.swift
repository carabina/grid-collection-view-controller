//
//  SimpleViewController.swift
//  PaginableTableView
//
//  Created by Julien Sarazin on 21/12/2016.
//  Copyright © 2016 Julien Sarazin. All rights reserved.
//

import UIKit

class SimpleViewController: UIViewController {
	@IBOutlet weak var containerView: UIView!

	var collectionController: GridCollectionViewController!
	var data: [String: [User]] = ["users": []]

    override func viewDidLoad() {
        super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

		self.collectionController = GridCollectionViewController()
		self.collectionController.register(UINib(nibName:String(describing:LoadingItemCell.self), bundle: Bundle.main), forCellWithReuseIdentifier: LoadingItemCell.Identifier)
		self.collectionController.register(UINib(nibName:String(describing:UserItemCell.self), bundle: Bundle.main), forCellWithReuseIdentifier: UserItemCell.Identifier)
		self.collectionController.setCollectionViewLayout(CenterAlignedFlowLayout(), animated: true)
		self.collectionController.delegate = self
		self.collectionController.dataSource = self
		self.collectionController.paginationEnabled = true
		self.view.addSubview(self.collectionController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func deviceRotated() {
		self.collectionController.collectionView?.reloadData()
	}
}

extension  SimpleViewController: GridCollectionViewControllerDataSource, GridCollectionViewControllerDelegate {
	// MARK: PaginableViewController Delegate
	func numberOfItemPerRow(_ collectionView: UICollectionView) -> CGFloat {
		return 5
	}

	func heightForItemAtIndexPath(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
		return 100
	}

	func loadingCellSize(collectionView: UICollectionView) -> CGSize {
		return CGSize(width: collectionView.frame.size.width/5, height: 50)
	}

	func shouldHideLoadingCellWhenNothingToLoad() -> Bool {
		return true
	}

	// MARK: PagniableViewController DataSource"
	func countPerPage(for section: Int) -> Int {
		return 3
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell: UserItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserItemCell.Identifier, for: indexPath) as? UserItemCell {
			let user = self.data["users"]![indexPath.row]

			cell.indexPath = indexPath
			cell.set(user: user)

			return cell
		}

		fatalError("Unhandled Error")
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.data.keys.count
	}

	func controller(_ controller: GridCollectionViewController, loadingCellAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell: LoadingItemCell = controller.collectionView!.dequeueReusableCell(withReuseIdentifier: LoadingItemCell.Identifier, for: indexPath) as? LoadingItemCell {
			cell.set(loading: controller.loading)
			return cell
		}

		fatalError("Unhandled Error")
	}

	func fetchData(from indexPath: IndexPath, with count: Int, completion: @escaping (Int) -> Void) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			let results = User.stub(from: indexPath.row, with: count)
			self.data["users"]!.append(contentsOf: results)
			completion(results.count)
		}
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.data["users"]!.count
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("Did select: [\(indexPath.section), \(indexPath.row)]")
	}
}
