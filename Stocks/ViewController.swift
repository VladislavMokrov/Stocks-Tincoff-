//
//  ViewController.swift
//  Stocks
//
//  Created by Владислав Мокров on 30.01.2021.
//

import UIKit

class ViewController: UIViewController {

    // UI
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    // Private
    private lazy var companies = [
        "Apple": "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB"
    ]
    
    // MARK: (Task 5)
    private func alertController() {
        let alertController = UIAlertController(
            title: "Ошибка!",
            message: "Отсутствует соединение с интернетом \n Или произошла ошибка сети",
            preferredStyle: UIAlertController.Style.alert)
            // добавляем кнопки к всплывающему сообщению
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // вывод всплывающего окна
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Lifecyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companyNameLabel.text = "Tinkoff"
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        requestQuoteUpdate()
    }
    
    //MARK: - Private
    
    private func requestQuoteUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        companySymbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        priceChangeLabel.textColor = .black
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: selectedSymbol)
//        requestQuoteImage(for: selectedSymbol)
    }

    
    private func requestQuote(for symbol: String) {
        let token = "pk_f47fe0785a3e474ba243362de79ed172"
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?&token=\(token)") else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data,
               (response as? HTTPURLResponse)?.statusCode == 200,
               error == nil {
                self?.parseQuote(from: data)
            } else {
                print("Network error!")
                DispatchQueue.main.async { self?.alertController() }
            }
        }
        dataTask.resume()
    }
    
    private func parseQuote(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double else { return print("Invalid JSON") }
            
            DispatchQueue.main.async { [ weak self ] in
                self?.displayStockInfo(companyName: companyName,
                                       companySymbol: companySymbol,
                                       price: price,
                                       priceChange: priceChange)
            }
        } catch {
            print("JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String,
                                  companySymbol: String,
                                  price: Double,
                                  priceChange: Double) {
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        companySymbolLabel.text = companySymbol
        priceLabel.text = "\(price)"
        priceChangeLabel.text = "\(priceChange)"
        
//MARK: - (Task 1) Changing color of label text priceChangeLabel
        switch priceChange {
        case -priceChange:
            priceChangeLabel.textColor = .green
        case +priceChange:
            priceChangeLabel.textColor = .red
        default:
            priceChangeLabel.textColor = .black
        }
    }
    
// MARK:  (Task 2) Не успел разобраться в данной задачей
//            private func requestQuoteImage(for symbol: String) {
//                guard let url = URL(string:"https:// storage.googleapis.com/iex/api/logos/{\(symbol)}.png") else {
//                    return
//                }
//
//                let task = URLSession.shared.dataTask(with: url) { data, response, error in
//                    guard let data = data, error == nil else { return }
//
//                    DispatchQueue.main.async() {    // execute on main thread
//                        self.imageView.image = UIImage(data: data)
//                    }
//                }
//                task.resume()
//            }
}

// MARK: - UIPickerViewDataSourse

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.keys.count
    }
}

// MARK: - UIPickerViewDelegate

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestQuoteUpdate()
    }
}
