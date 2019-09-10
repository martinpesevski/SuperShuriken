//
//  StoreManager.swift
//  SuperShuriken
//
//  Created by Martin Peshevski on 5/23/19.
//  Copyright © 2019 MP. All rights reserved.
//

import Foundation
import StoreKit

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased
    
    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully purchased this item!"
        }
    }
}

class StoreManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    private static let disableAdsIdentifier = "com.mpesevski.superShuriken.disableads"
    
    private var productID = ""
    private var products = [SKProduct]()
    private var productRequest = SKProductsRequest()
    
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
    
    func restorePurchase() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func fetchAvailableProducts() {
        let productIDS: Set<String> = [StoreManager.disableAdsIdentifier]
        
        productRequest = SKProductsRequest(productIdentifiers: productIDS)
        productRequest.delegate = self
        productRequest.start()
    }
    
    //MARK: - delegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else { return }
        
        products = response.products
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        
        for product in products {
            numberFormatter.locale = product.priceLocale
            let price1Str = numberFormatter.string(from: product.price) ?? ""
            print(product.localizedDescription + "\nfor just \(price1Str)")
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                purchaseStatusBlock?(.purchased)
            case .failed:
                print("failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
}
