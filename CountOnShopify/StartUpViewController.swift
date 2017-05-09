//
//  StartUpViewController.swift
//  CountOnShopify
//
//  Created by Nathaniel Ruiz on 2017-05-05.
//  Copyright © 2017 Nathaniel Ruiz. All rights reserved.
//

import UIKit

private let itemsForSaleCellIdentifier = "StartUpCellIdentifier"

class StartUpViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	@IBOutlet weak var startUpCollectionView: UICollectionView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var visualEffectViewTitle: UIVisualEffectView!

	let infoForItemCell = StartUpAvailableProduct()
	var startUpCellSideSize = (UIScreen.main.bounds.width / 2) - 15

    override func viewDidLoad() {
        super.viewDidLoad()
		self.registerItems()
		self.setUpDelegates()
		self.adjustCollectionInsets()
    }

	override func viewWillAppear(_ animated: Bool) {
		self.adjustForScreenOrientation()
	}

	func adjustForScreenOrientation() {
		switch UIApplication.shared.statusBarOrientation {
		case .portrait, .portraitUpsideDown : self.startUpCellSideSize = UIScreen.main.bounds.width / 2 - 15
		case .landscapeRight, .landscapeLeft : self.startUpCellSideSize = UIScreen.main.bounds.width / 3 - 30
		default : break
		}
	}

	func registerItems() {
		self.startUpCollectionView!.register(UINib(nibName: "StartUpCellView", bundle: nil), forCellWithReuseIdentifier: itemsForSaleCellIdentifier)
	}

	func setUpDelegates() {
		self.startUpCollectionView.delegate = self
		self.startUpCollectionView.dataSource = self
	}

	func adjustCollectionInsets() {
		self.startUpCollectionView.contentInset.top = self.visualEffectViewTitle.frame.height + 10
	}

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.infoForItemCell.productsForSale.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let startUpCell = collectionView.dequeueReusableCell(withReuseIdentifier: itemsForSaleCellIdentifier, for: indexPath) as! StartUpCollectionViewCell
		startUpCell.itemLabel.text = self.infoForItemCell.productsForSale[indexPath.item]
        return startUpCell
    }

	//MARK: UICollectionViewDelegateFlowLayout

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let sizeForCellCoreGraphics = CGSize(width: self.startUpCellSideSize, height: self.startUpCellSideSize)
		return sizeForCellCoreGraphics
	}

    // MARK: UICollectionViewDelegate

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemCellSelected = self.startUpCollectionView.cellForItem(at: indexPath) as? StartUpCollectionViewCell,
			let statisticsViewController = storyboard?.instantiateViewController(withIdentifier: "StatisticsViewControllerIdentifier") as? StatisticsViewController else { return }
		statisticsViewController.statisticsDataSource.nameOfItem = itemCellSelected.itemLabel.text!
		self.activityIndicator.startAnimating()
		self.activityIndicator.isHidden = false
		self.view.alpha = 0.5
		statisticsViewController.statisticsDataSource.importAndParseShopifyOrders(foritem: itemCellSelected.itemLabel.text!) {
			statisticsViewController.statisticsDataSource.unitsSoldOfItem = String(statisticsViewController.statisticsDataSource.revenueFromItem)
			statisticsViewController.statisticsDataSource.unitsSoldOfItem = String(statisticsViewController.statisticsDataSource.arrayOfOrders.count)
			self.activityIndicator.stopAnimating()
			self.activityIndicator.isHidden = true
			self.view.alpha = 1
			self.navigationController?.pushViewController(statisticsViewController, animated: true)
		}
	}
}
