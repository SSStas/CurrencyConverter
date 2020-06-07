//
//  DataAndClasses.swift
//  CurrencyConverter
//
//  Created by Mac on 02.06.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import SwiftUI


struct source: Codable {
    var base: String?
    var date: String?
    var rates: [String: Double]?
    var error: String?
}


class ExchangeRates: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var base: String? = nil
    @Published var date: Date? = nil
    @Published var error: String? = nil
    
    init() {
        self.setRates()
    }
    
    func setRates(base: String? = nil, date: Date? = nil) {
        self.error = nil
        let b = (base == nil) ? ((self.base == nil) ? "" : "?base=" + self.base! ) : "?base=" + base!
        let d = (date == nil) ? ((self.date == nil) ? "latest" : Date.ToString(self.date!)) : Date.ToString(date!)
        let link = "https://api.exchangeratesapi.io/" + d + b
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            if err != nil {
                self.error = "Неизвестная ошибка"
                return
            }
            if data != nil {
                let info = try! JSONDecoder().decode(source.self, from: data!)
                DispatchQueue.main.async {
                    if info.error == nil {
                        self.base = info.base
                        self.date = Date.FromString(info.date!)
                        self.rates = info.rates!
                        if let baseRate = info.base { self.rates[baseRate] = 1.0 }
                    } else {
                        self.error = info.error!
                    }
                }
            } else {
                self.error = "Ошибка загрузки данных"
            }
        }
        .resume()
    }
    
    func convert(num: Double?, rate: String, isReversed: Bool = false) -> String {
        return self.rates[rate] != nil && num != nil ?
            String(format: "%.4f", (!isReversed ? num! * self.rates[rate]! : num! / self.rates[rate]!)) : "--"
    }
}


extension Date {
    public static func FromString(_ dateString: String, _ format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }
    
    public static func ToString(_ date: Date, _ format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}


extension View {
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force) }
    }
}
