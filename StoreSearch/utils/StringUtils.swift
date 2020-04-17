//
//  StringUtils.swift
//  StoreSearch
//
//  Created by Wilfred Asomani on 17/04/2020.
//  Copyright © 2020 Wilfred Asomani. All rights reserved.
//

import Foundation

extension String {

    static func format(price: Double, currency: String? = "USD") -> String {
        guard price > 0 else { return "Free" }
        let formatter = NumberFormatter()
        formatter.currencyCode = currency
        formatter.numberStyle = .currency
        return formatter.string(from: price as NSNumber) ?? ""
    }
}
