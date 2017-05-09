//
//  StatisticsViewController.swift
//  CountOnShopify
//
//  Created by Nathaniel Ruiz on 2017-05-05.
//  Copyright © 2017 Nathaniel Ruiz. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

	let statisticsDataSource = StatisticsModel()

	@IBOutlet weak var itemsTitleLabel: UILabel!
	@IBOutlet weak var allProductsRevenueLabel: UILabel!
	@IBOutlet weak var itemOnlyRevenue: UILabel!
	@IBOutlet weak var unitsLabel: UILabel!

	override func viewWillAppear(_ animated: Bool) {
		self.itemsTitleLabel.text = statisticsDataSource.nameOfItem
		self.itemOnlyRevenue.text = "$" + statisticsDataSource.revenueFromItem
		self.unitsLabel.text = statisticsDataSource.unitsSoldOfItem
		self.allProductsRevenueLabel.text = "$" + String(statisticsDataSource.revenueGeneratedFromAllProducts)
	}
}
