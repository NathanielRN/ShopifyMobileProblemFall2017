//
//  StatisticsModel.swift
//  CountOnShopify
//
//  Created by Nathaniel Ruiz on 2017-05-05.
//  Copyright © 2017 Nathaniel Ruiz. All rights reserved.
//

import Foundation

struct ShopifyOrders {
	var itemPrice: Double
}

class StatisticsModel {

	let shopifyURL = "https://shopicruit.myshopify.com/admin/orders.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"

	var nameOfItem = "No item selected"
	var revenueFromItem = "No revenue calculated yet"
	var unitsSoldOfItem = "No units sold yet"
	var revenueGeneratedFromAllProducts = 0.0

	var arrayOfOrders = [ShopifyOrders]()

	func importAndParseShopifyOrders(foritem itemName: String, _ importCompletionCallback: @escaping (() -> ())) {
		DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
			let urlToGetOrdersFrom = URL(string: self.shopifyURL)
			var requestForOrders = URLRequest(url: urlToGetOrdersFrom!)
			requestForOrders.httpMethod = "GET"
			requestForOrders.addValue("application/json", forHTTPHeaderField: "Accept")

			let configurationsForSession = URLSessionConfiguration.default
			let sessionFromURL = URLSession(configuration: configurationsForSession)

			let receiveTask = sessionFromURL.dataTask(with: requestForOrders) { [weak self] (data, response, error) in
				guard let strongSelf = self,
					error == nil,
					let unwrappedRecievedArray = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! Dictionary<String, Any>,
					let unwrappedOrdersArray = unwrappedRecievedArray["orders"] as? [Dictionary<String, Any>] else { return }
				DispatchQueue.main.async {
					strongSelf.parseAndAddOrders(forThisItem: itemName, fromArray: unwrappedOrdersArray, importCompletionCallback)
				}
			}
			receiveTask.resume()
		}
	}

	func parseAndAddOrders(forThisItem nameOfItem: String, fromArray receivedArray: [Dictionary<AnyHashable, Any>], _ waitingForCompletionCallback: @escaping (() -> ())) {
		self.arrayOfOrders = []
		for orderReceived in receivedArray {
			self.revenueGeneratedFromAllProducts += Double(orderReceived["subtotal_price"] as! String)!
			if let unwrappedOrderAsDictionary = orderReceived as? [String: Any] {
				self.convertDataIntoShopifyOrder(lookingForItem: nameOfItem, withInfo: unwrappedOrderAsDictionary)
			}
		}
		self.calculateRevenueGenerated(waitingForCompletionCallback)
	}

	func convertDataIntoShopifyOrder(lookingForItem thisItem: String, withInfo receivedInfo: [String: Any]) {
		if let unwrappedArrayOfPurchasedItems = receivedInfo["line_items"] as? [[String: Any]] {
			for itemPurchased in unwrappedArrayOfPurchasedItems {
				if itemPurchased["title"] as? String == thisItem {
					guard let priceStringAsFloat = Double(itemPurchased["price"] as! String) else { return }
					let additionalItems = itemPurchased["quantity"] as? Int
					for _ in 1...additionalItems! {
						let shopifyOrder = ShopifyOrders(itemPrice: priceStringAsFloat)
						self.arrayOfOrders.append(shopifyOrder)
					}
					return
				}
			}
		} else {
			return
		}
	}

	func calculateRevenueGenerated(_ finalStepBeforeCompletionCallback: (() -> ())) {
		var revenueGeneratedFromKeyboard = 0.0
		for confirmedItemOrder in self.arrayOfOrders {
			revenueGeneratedFromKeyboard += confirmedItemOrder.itemPrice
		}
		self.revenueFromItem = String(format: "%.2f", revenueGeneratedFromKeyboard)
		finalStepBeforeCompletionCallback()
	}
}
