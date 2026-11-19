import Foundation

enum TxType: String, Codable, CaseIterable {
    case expense = "支出"
    case income = "收入"
}

enum Payment: String, Codable, CaseIterable {
    case wechat = "微信"
    case alipay = "支付宝"
    case cash = "现金"
    case card = "银行卡"
}

struct TransactionItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var type: TxType
    var amount: Double
    var category: String
    var payment: Payment
    var date: Date
    var note: String
}

enum Categories {
    static let expense = ["餐饮","交通","购物","居住","水电网","医疗","教育","娱乐","服饰","日用品","宠物","其他"]
    static let income = ["工资","奖金","兼职","理财","红包","其他"]
    static func list(for type: TxType) -> [String] { type == .expense ? expense : income }
}
