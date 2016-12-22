//
//  User.swift
//  PaginableTableView
//
//  Created by Julien Sarazin on 19/12/2016.
//  Copyright © 2016 Julien Sarazin. All rights reserved.
//

import UIKit

class User: NSObject {
	var firstName: String = "unknown"
	var lastName: String = "unknown"
	var company: String = "unkown"

	static let list: [User] = [
		User(firstName: "foo", lastName: "bar", company: "baz"),
		User(firstName: "foo", lastName: "bar", company: "bax"),
		User(firstName: "foo", lastName: "bar", company: "baw"),
		User(firstName: "foo", lastName: "bar", company: "bal"),
		User(firstName: "foo", lastName: "bar", company: "baj"),
		User(firstName: "foo", lastName: "bar", company: "bah"),
		User(firstName: "foo", lastName: "bar", company: "bag"),
		User(firstName: "foo", lastName: "bar", company: "baf"),
		User(firstName: "foo", lastName: "bar", company: "bad"),
		User(firstName: "foo", lastName: "bar", company: "bas"),
		User(firstName: "foo", lastName: "bar", company: "baq"),
		User(firstName: "foo", lastName: "bar", company: "bap"),
		User(firstName: "foo", lastName: "bar", company: "bao"),
		User(firstName: "foo", lastName: "bar", company: "bai"),
		User(firstName: "foo", lastName: "bar", company: "bau"),
		User(firstName: "foo", lastName: "bar", company: "bat"),
		User(firstName: "foo", lastName: "bar", company: "bae"),
		User(firstName: "foo", lastName: "bar", company: "baa"),
		User(firstName: "foo", lastName: "bar", company: "bad")
	]

	convenience init(firstName: String, lastName: String, company: String) {
		self.init()

		self.firstName = firstName
		self.lastName = lastName
		self.company = company
	}
}

extension User {
	static func from(_ dict: [String: Any]) -> User {
		let user = User()
		user.firstName	= dict["name.first"] as? String ?? "unkown"
		user.lastName	= dict["name.last"] as? String ?? "unkown"
		user.company	= dict["company"] as? String ?? "unkown"

		return user
	}
}

extension User {
	static func stub(from: Int, with count: Int) -> [User] {
		let start = min(from, self.list.count)
		let end = min(from+count, self.list.count - 1)

		return Array(self.list[start...end])
	}
}
