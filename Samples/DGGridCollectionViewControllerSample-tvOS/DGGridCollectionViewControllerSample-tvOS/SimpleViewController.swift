//
//  SimpleViewController.swift
//  PaginableTableView
//
//  Created by Julien Sarazin on 21/12/2016.
//  Copyright © 2016 Julien Sarazin. All rights reserved.
//

import UIKit
import DGGridCollectionViewController

class SimpleViewController: UIViewController {
	var collectionController: DGGridCollectionViewController!
	var data: [String: [User]] = ["users": []]

    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Demo"

		self.collectionController = DGGridCollectionViewController()
		self.collectionController.register(UINib(nibName:String(describing:LoadingItemCell.self), bundle: Bundle.main), forCellWithReuseIdentifier: LoadingItemCell.Identifier)
		self.collectionController.register(UINib(nibName:String(describing:UserItemCell.self), bundle: Bundle.main), forCellWithReuseIdentifier: UserItemCell.Identifier)
		self.collectionController.setCollectionViewLayout(DGCenterAlignedFlowLayout(), animated: true)
		self.collectionController.delegate = self
		self.collectionController.dataSource = self
		self.collectionController.paginationEnabled = true
        self.collectionController.view?.frame = self.view.bounds
		self.collectionController.collectionView?.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
		self.view.addSubview(self.collectionController.view)
    }
}

extension  SimpleViewController: DGGridCollectionViewControllerDataSource, DGGridCollectionViewControllerDelegate {
	// MARK: Flow Layout
	// Flow layout delegate
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets()
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}

	// MARK: PaginableViewController DelegatE

	func numberOfItemPerRow(_ collectionView: UICollectionView) -> Int {
		return 10
	}

	func heightForItemAtIndexPath(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
		return 200
	}

	func loadingCellSize(collectionView: UICollectionView) -> CGSize {
		return CGSize(width: collectionView.frame.size.width/5, height: 100)
	}

	func shouldHideLoadingCellWhenNothingToLoad() -> Bool {
		return true
	}

	// MARK: PagniableViewController DataSource"
	func countPerPage(for section: Int) -> Int {
		return 5
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

	func controller(_ controller: DGGridCollectionViewController, loadingCellAt indexPath: IndexPath) -> UICollectionViewCell {
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
