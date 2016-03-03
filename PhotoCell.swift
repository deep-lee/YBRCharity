//
//  PhotoCell.swift
//  YBRCharity
//
//  Created by 李冬 on 16/2/24.
//  Copyright © 2016年 李冬. All rights reserved.
//

import UIKit
import SwiftyFORM

class PhotoCell: UITableViewCell, CellHeightProvider {

	@IBOutlet var photoNameLabel: UILabel!
	@IBOutlet var photoImageView: UIImageView!
	var xibHeight: CGFloat = 103
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		xibHeight = bounds.height
	}

	static func createCell() throws -> PhotoCell {
		let cell: PhotoCell = try NSBundle.mainBundle().form_loadView("PhotoCell")
		return cell
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	func form_cellHeight(indexPath: NSIndexPath, tableView: UITableView) -> CGFloat {
		return xibHeight
	}
}
