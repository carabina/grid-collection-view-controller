//
//  UserItemCell.swift
//  PaginableTableView
//
//  Created by Julien Sarazin on 19/12/2016.
//  Copyright © 2016 Julien Sarazin. All rights reserved.
//

import UIKit

class UserItemCell: UICollectionViewCell {
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var companyLabel: UILabel!

	var indexPath: IndexPath?
	static let Identifier = "UserItemCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func set(user: User) {
		self.nameLabel.text = "\(indexPath!.row)"
		self.companyLabel.text = user.company

		self.nameLabel.layer.borderColor = UIColor.black.cgColor
		self.nameLabel.layer.borderWidth = 0.5
	}
}
