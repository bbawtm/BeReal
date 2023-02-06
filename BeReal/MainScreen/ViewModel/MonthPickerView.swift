//
//  MonthPickerView.swift
//  BeReal
//
//  Created by Vadim Popov on 05.02.2023.
//

import UIKit


// MARK: MonthPickerView

class MonthPickerView: UIPickerView  {

    enum Component: Int {
        case Month = 0
        case Year = 1
    }

    let LABEL_TAG = 43

    let months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    var years: [String] {
        var years: [String] = []
        for i in minYear...maxYear {
            years.append("\(i)")
        }
        return years
    }

    var rowHeight: NSInteger = 40
    
    var month: String {
        self.months[selectedRow(inComponent: Component.Month.rawValue) % months.count]
    }
    
    var year: String {
        self.years[selectedRow(inComponent: Component.Year.rawValue) % years.count]
    }

    var date: Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        formatter.timeZone = .gmt
        return formatter.date(from: "\(self.month) \(self.year)")!
    }

    var minYear: Int!
    var maxYear: Int!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadDefaultParameters()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadDefaultParameters()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        loadDefaultParameters()
    }

    func loadDefaultParameters() {
        minYear = 2000
        maxYear = Calendar.current.dateComponents([.year], from: Date()).year

        self.delegate = self
        self.dataSource = self
    }
    
    func selectToday() {
        selectRow(todayIndexPath.row, inComponent: Component.Month.rawValue, animated: false)
        selectRow(todayIndexPath.section, inComponent: Component.Year.rawValue, animated: false)
    }


    var todayIndexPath: NSIndexPath {
        let row = Double(months.firstIndex(of: currentMonthName) ?? months.startIndex)
        let section = Double(years.firstIndex(of: currentYearName) ?? years.startIndex)

        return NSIndexPath(row: Int(row), section: Int(section))
    }

    var currentMonthName: String {
        let formatter = DateFormatter()
        let locale = Locale.init(identifier: "ru_RU")
        formatter.locale = locale
        formatter.dateFormat = "LLLL"
        formatter.timeZone = .gmt
        return formatter.string(from: Date()).capitalized
    }

    var currentYearName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.timeZone = .gmt
        return formatter.string(from: Date())
    }

    func titleForRow(row: Int, forComponent component: Int) -> String? {
        if component == Component.Month.rawValue {
            return self.months[row % self.months.count]
        }
        return self.years[row % self.years.count]
    }


    func labelForComponent(component: NSInteger) -> UILabel {
        let frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: CGFloat(rowHeight))
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.tag = LABEL_TAG
        return label
    }
}

extension MonthPickerView: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == Component.Month.rawValue) {
            return months.count
        } else {
            return years.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.bounds.size.width / 2.0
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var returnView: UILabel
        if view?.tag == LABEL_TAG {
            returnView = view as! UILabel
        } else {
            returnView = labelForComponent(component: component)
        }

        returnView.text = titleForRow(row: row, forComponent: component)
        
        return returnView
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(rowHeight)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
}


// MARK: - TextField MonthPicker

extension UITextField {
    
    func setMonthPickerAsInputView(selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        
        let datePicker = MonthPickerView()
        datePicker.selectToday()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        self.inputView = datePicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(tapCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: selector)
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        self.inputAccessoryView = toolbar
        
        self.text = "\(datePicker.currentMonthName) \(datePicker.currentYearName)"
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
}
