import Foundation

@MainActor
final class Store: ObservableObject {
    @Published var items: [TransactionItem] = [] {
        didSet { save() }
    }
    @Published var monthlyBudget: Double = 5000 {
        didSet { UserDefaults.standard.set(monthlyBudget, forKey: "monthlyBudget") }
    }
    private let key = "xiaoyumu.transactions.v1"
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([TransactionItem].self, from: data) {
            items = decoded
        }
        let b = UserDefaults.standard.double(forKey: "monthlyBudget")
        if b > 0 { monthlyBudget = b }
    }
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    func add(_ item: TransactionItem) { items.append(item) }
    func update(_ item: TransactionItem) {
        if let i = items.firstIndex(where: { $0.id == item.id }) { items[i] = item }
    }
    func delete(_ item: TransactionItem) { items.removeAll { $0.id == item.id } }
    func items(inMonthOf date: Date) -> [TransactionItem] {
        let cal = Calendar.current
        return items.filter { cal.isDate($0.date, equalTo: date, toGranularity: .month) && cal.isDate($0.date, equalTo: date, toGranularity: .year) }
            .sorted { $0.date > $1.date }
    }
    func exportCSV(inMonthOf date: Date) -> String {
        var lines = ["日期,类型,分类,金额,支付方式,备注"]
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        for it in items(inMonthOf: date) {
            lines.append("\(fmt.string(from: it.date)),\(it.type.rawValue),\(it.category),\(String(format: "%.2f", it.amount)),\(it.payment.rawValue),\(it.note.replacingOccurrences(of: ",", with: "，"))")
        }
        return lines.joined(separator: "\n")
    }
}
