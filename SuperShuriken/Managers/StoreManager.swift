//
//  StoreManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/23/19.
//  Copyright © 2019 MP. All rights reserved.
//

import Foundation
import StoreKit

enum AvailableProducts: String {
    case disableAds = "com.mpesevski.superShuriken.disableads"
}

enum IAPHandlerAlertType {
    case disabled
    case purchased
    case canceled
    
    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .purchased: return "You've successfully purchased this item!"
        case .canceled: return "Purchase cancelled!"
        }
    }
}

class StoreManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    
    private var productID = ""
    private var products = [SKProduct]()
    private var productRequest = SKProductsRequest()
    private var productHandler: (() -> ())? = nil
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchase(index: Int) {
        guard canMakePurchases(), products.count > 0 else {
            purchaseStatusBlock?(.disabled)
            return
        }
        
        let product = products[index]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        
        print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
        productID = product.productIdentifier
    }
    
    func fetchAvailableProducts(completion: (() -> ())?) {
        productHandler = completion
        let productIDS: Set<String> = [AvailableProducts.disableAds.rawValue]
        
        productRequest = SKProductsRequest(productIdentifiers: productIDS)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func isPurchased(_ product: AvailableProducts) -> Bool {
        var purchased = false
        for prod in products where prod.productIdentifier == product.rawValue {
            purchased = true
        }
        return purchased
    }
    
    //MARK: - delegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productHandler?()
        guard response.products.count > 0 else { return }
        
        products = response.products
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        
        for product in products {
            numberFormatter.locale = product.priceLocale
            let price1Str = numberFormatter.string(from: product.price) ?? ""
            print(product.localizedDescription + " for just \(price1Str)")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                purchaseStatusBlock?(.purchased)
            default:
                purchaseStatusBlock?(.canceled)
            }
        }
    }
}
