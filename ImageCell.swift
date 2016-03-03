//
//  ImageCell.swift
//  YBRCharity
//
//  Created by 李冬 on 16/3/3.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyFORM

protocol ImageCellDelegate {
	func clickAction()
}

class ImageCell: UITableViewCell, CellHeightProvider, SelectRowDelegate {

	@IBOutlet var label: NSLayoutConstraint!
	@IBOutlet var imageview: UIImageView!
	var xibHeight: CGFloat = 100
	var delegate: ImageCellDelegate!
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		xibHeight = bounds.height
	}

	static func createCell(delegate: ImageCellDelegate) throws -> ImageCell {
		let cell: ImageCell = try NSBundle.mainBundle().form_loadView("ImageCell")
		cell.delegate = delegate
		return cell
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	func form_cellHeight(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat {
		return xibHeight
	}

	public func form_didSelectRow(indexPath: NSIndexPath, tableView: UITableView) {
		delegate.clickAction()
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
