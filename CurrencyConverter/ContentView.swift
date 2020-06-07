//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Mac on 02.06.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import SwiftUI


struct DateChooseView: View {
    
    @EnvironmentObject var exchangeRates: ExchangeRates
    @State var choosenDate: Date
    @Binding var showDateView: Bool
    
    var body: some View {
        Group {
            Spacer()
            
            DatePicker(selection: $choosenDate, in: Date.FromString("1999-01-04")!...Date(), displayedComponents: .date) {
                EmptyView()
            }
            .padding(10.0)
            
            Button(action: {
                self.exchangeRates.setRates(date: self.choosenDate)
                self.showDateView.toggle()
            }) {
                Text("Готово")
                    .foregroundColor(Color("TextColor"))
            }
            .font(.callout)
            .padding(.horizontal, 10.0)
            .padding(.bottom, 20.0)
            
            Button(action: {
                self.showDateView.toggle()
            }) {
                Text("Отмена")
                    .foregroundColor(Color("TextColor"))
            }
            .font(.callout)
            .padding(.horizontal, 10.0)
            .padding(.bottom, 30.0)
        }
    }
}


struct ContentView: View {
    
    @EnvironmentObject var exchangeRates: ExchangeRates
    @State var fixed: String? = "USD"
    @State var number: String = "1.0"
    @State var choosen: Bool?
    @State var reversing: Bool = false
    @State var showDateSheet: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { self.showDateSheet.toggle() }) {
                            Text("на " + ((self.exchangeRates.date != nil) ? Date.ToString(self.exchangeRates.date!, "dd.MM.yyyy") : "--.--.----"))
                                .foregroundColor(self.showDateSheet ? .green : Color("TextColor"))
                                .font(.system(size: 20))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5.0)
                    Text("according to the ECB")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TextColor"))
                        .padding(.bottom, 5.0)
                }
                .background(Color("BackgroundColor"))
                .cornerRadius(10)
                .padding(10.0)
                
                VStack(alignment: .leading) {
                    Button(action: {
                        self.choosen = (self.choosen != true) ? true : nil
                    }) {
                        Text(self.exchangeRates.base ?? "--")
                            .font(.system(size: 20))
                            .foregroundColor(self.choosen == true ? .green : Color("TextColor"))
                            .padding(10.0)
                    }
                    TextField("Сумма", text: $number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.horizontal, .bottom], 10.0)
                        .cornerRadius(10)
                }
                .background(Color("BackgroundColor"))
                .cornerRadius(10)
                .padding(.horizontal, 10.0)
                
                HStack {
                    VStack(alignment: .leading) {
                        Button(action: {
                            self.choosen = (self.choosen != false) ? false : nil
                        }) {
                            Text(self.fixed ?? "--")
                                .font(.system(size: 20))
                                .foregroundColor(self.choosen == false ? .green : Color("TextColor"))
                                .padding(10.0)
                        }
                        Text(self.exchangeRates.convert(num: Double(self.number), rate: self.fixed ?? ""))
                            .font(.system(size: 20))
                            .padding([.horizontal, .bottom], 10.0)
                        
                    }
                    Spacer()
                    Button(action: {
                        if !self.reversing {
                            self.reversing.toggle()
                            let newRate = self.fixed
                            self.fixed = self.exchangeRates.base
                            self.exchangeRates.setRates(base: newRate)
                            self.reversing.toggle()
                        }
                    }) {
                        Image("arrow.right.arrow.left")
                            .foregroundColor(Color("TextColor"))
                    }
                    .padding(.horizontal, 10.0)
                }
                .background(Color("BackgroundColor"))
                .cornerRadius(10)
                .padding(.horizontal, 10.0)
                
                if !self.showDateSheet {
                    List() {
                        ForEach(self.exchangeRates.rates.sorted(by: <), id: \.key) { key, _ in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(key)")
                                    Text("\(self.exchangeRates.convert(num: Double(self.number), rate: key))")
                                }
                                if self.choosen != nil {
                                    Spacer()
                                    Text("Выбрать")
                                }
                            }
                            .onTapGesture {
                                if self.choosen != nil {
                                    if self.choosen! {
                                        self.exchangeRates.setRates(base: key)
                                    } else {
                                        self.fixed = key
                                    }
                                    self.choosen = nil
                                }
                            }
                        }
                    }
                } else {
                    DateChooseView(choosenDate: self.exchangeRates.date ?? Date(), showDateView: self.$showDateSheet)
                }
            }
            .navigationBarTitle("Конвертация валют", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: { self.exchangeRates.setRates() }) {
                    Image("arrow.2.circlepath")
                        .foregroundColor(Color("TextColor"))
                })
            .keyboardType(.decimalPad)
            .onTapGesture {
               self.endEditing(true)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
