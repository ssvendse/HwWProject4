//
//  ResultsInterfaceController.swift
//  HwWProject4 WatchKit Extension
//
//  Created by Skyler Svendsen on 12/17/17.
//  Copyright © 2017 Skyler Svendsen. All rights reserved.
//

import WatchKit
import Foundation


class ResultsInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var status: WKInterfaceLabel!
    @IBOutlet var done: WKInterfaceButton!
    
    var fetchedCurrencies = [(symbol: String, rate: Double)]()
    var amountToConvert = 0.0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let settings = context as? [String: String] else { return }
        guard let amount = settings["amount"] else { return }
        guard let baseCurrency = settings["base"] else { return }
        
        amountToConvert = Double(amount) ?? 50
        setTitle("\(amount) \(baseCurrency)")
        
        let defaults = UserDefaults.standard
        let selectedCurrencies = defaults.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchData(for: baseCurrency, symbols: selectedCurrencies)
        }
    }
    
    @IBAction func doneTapped() {
        WKInterfaceController.reloadRootPageControllers(withNames: ["Home", "Currencies"], contexts: nil, orientation: .horizontal, pageIndex: 0)
        
    }
    
    func fetchData(for baseCurrency: String, symbols: [String]) {
        if let url = URL(string: "https://api.fixer.io/latest?base=\(baseCurrency)&symbols=\(symbols.joined(separator: ","))") {
            let urlRequest = URLRequest(url: url)
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let data = data {
                    self.parse(data)
                } else {
                    DispatchQueue.main.async {
                        self.status.setText("Fetch failed")
                        self.done.setHidden(false)
                    }
                }
                }.resume()
        }
    }
    
    func parse(_ contents: Data) {
        let json = JSON(data: contents)
        let rates = json["rates"].dictionaryValue
        
        for symbol in rates {
            let rateName = symbol.key
            let rateValue = symbol.value.doubleValue
            fetchedCurrencies.append((symbol: rateName, rate: rateValue))
        }
        
        fetchedCurrencies.sort {
            $0.symbol < $1.symbol
        }
        
        updateTable()
        status.setHidden(true)
        table.setHidden(false)
        done.setHidden(false)
    }
    
    func updateTable() {
        table.setNumberOfRows(fetchedCurrencies.count, withRowType: "Row")
        
        for (index, currency) in fetchedCurrencies.enumerated() {
            guard let row = table.rowController(at: index) as? CurrencyRow else { return }
            
            let value = currency.rate * amountToConvert
            let formattedValue = String(format: "%.2f", value)
            
            row.textLabel.setText("\(formattedValue) \(currency.symbol)")
        }
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        WKExtension.shared().isAutorotating = true
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        WKExtension.shared().isAutorotating = false
    }

}
