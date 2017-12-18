//
//  InterfaceController.swift
//  HwWProject4 WatchKit Extension
//
//  Created by Skyler Svendsen on 12/17/17.
//  Copyright © 2017 Skyler Svendsen. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var amountLabel: WKInterfaceLabel!
    @IBOutlet var amountSlider: WKInterfaceSlider!
    @IBOutlet var currencyPicker: WKInterfacePicker!
    
    static let currencies = ["AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "SGD", "USD"]
    static let defaultCurrencies = ["USD","EUR"]
    static let selectedCurrenciesKey = "SelectedCurrencies"
    
    var currentCurrency = "AUD"
    var currentAmount = 500
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var items = [WKPickerItem]()
        
        for currency in InterfaceController.currencies {
            let item = WKPickerItem()
            item.title = currency
            items.append(item)
        }
        
        currencyPicker.setItems(items)
    }
    
    @IBAction func convertTapped() {
        let context = ["amount": String(currentAmount), "base": currentCurrency]
        
        WKInterfaceController.reloadRootPageControllers(withNames: ["Results"], contexts: [context], orientation: .horizontal, pageIndex: 0)
    }
    
    @IBAction func amountChanged(_ value: Float) {
        currentAmount = Int(value)
        amountLabel.setText(String(currentAmount))
    }
    
    @IBAction func baseCurrencyChanged(_ value: Int) {
        currentCurrency = InterfaceController.currencies[value]
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
