import SwiftUI

func moneyText(_ value: Double) -> String {
    return "¥" + String(format: "%.2f", value)
}

struct TransactionRow: View {
    let item: TransactionItem

    private var subtitle: String {
        let label = item.note.isEmpty ? item.payment.rawValue : item.note
        let fmt = DateFormatter()
        fmt.dateFormat = "M月d日"
        return label + " · " + fmt.string(from: item.date)
    }

    private var amountText: String {
        let sign = item.type == .expense ? "-" : "+"
        return sign + moneyText(item.amount)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.category)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(amountText)
                .foregroundStyle(item.type == .expense ? Color.primary : Color.green)
        }
    }
}

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var month = Date()
    @State private var showingAdd = false
    @State private var editing: TransactionItem?
    @State private var search = ""

    var monthItems: [TransactionItem] {
        let base = store.items(inMonthOf: month)
        if search.isEmpty { return base }
        return base.filter { item in
            item.category.contains(search) || item.note.contains(search)
        }
    }

    var income: Double {
        let incomes = monthItems.filter { item in item.type == .income }
        return incomes.reduce(0) { sum, item in sum + item.amount }
    }

    var expense: Double {
        let expenses = monthItems.filter { item in item.type == .expense }
        return expenses.reduce(0) { sum, item in sum + item.amount }
    }

    private var budgetTitle: String {
        return "本月预算 " + moneyText(store.monthlyBudget)
    }

    private var budgetDetail: String {
        let remaining = max(store.monthlyBudget - expense, 0)
        return "已支出 " + moneyText(expense) + "，剩余 " + moneyText(remaining)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                List {
                    Section {
                        ForEach(monthItems) { item in
                            Button {
                                editing = item
                            } label: {
                                TransactionRow(item: item)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                store.delete(monthItems[index])
                            }
                        }
                    } header: {
                        Text("明细")
                    }
                    Section(budgetTitle) {
                        ProgressView(value: min(expense, store.monthlyBudget), total: max(store.monthlyBudget, 1))
                        Text(budgetDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Button("预算 -500") { store.monthlyBudget = max(500, store.monthlyBudget - 500) }
                            Spacer()
                            Button("预算 +500") { store.monthlyBudget += 500 }
                        }
                        .font(.caption)
                    }
                    Section {
                        ShareLink(item: store.exportCSV(inMonthOf: month)) {
                            Label("导出本月 CSV", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $search, prompt: "搜索账单")
            }
            .navigationTitle("榆木记账")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditorView { newItem in store.add(newItem) }
            }
            .sheet(item: $editing) { item in
                EditorView(existing: item) { updated in store.update(updated) }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    month = Calendar.current.date(byAdding: .month, value: -1, to: month) ?? month
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(month, format: .dateTime.year().month())
                    .font(.headline)
                Spacer()
                Button {
                    month = Calendar.current.date(byAdding: .month, value: 1, to: month) ?? month
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            Text("本月结余")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(moneyText(income - expense))
                .font(.largeTitle.bold())
            HStack(spacing: 24) {
                Text("收入 " + moneyText(income))
                    .foregroundStyle(.green)
                Text("支出 " + moneyText(expense))
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }
}

struct EditorView: View {
    @Environment(\.dismiss) private var dismiss
    var existing: TransactionItem? = nil
    var onSave: (TransactionItem) -> Void
    @State private var type: TxType = .expense
    @State private var amountText = ""
    @State private var category = "餐饮"
    @State private var payment: Payment = .wechat
    @State private var date = Date()
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("类型", selection: $type) {
                    ForEach(TxType.allCases, id: \.self) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                TextField("金额", text: $amountText)
                    .keyboardType(.decimalPad)
                Picker("分类", selection: $category) {
                    ForEach(Categories.list(for: type), id: \.self) { c in
                        Text(c).tag(c)
                    }
                }
                Picker("支付方式", selection: $payment) {
                    ForEach(Payment.allCases, id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                DatePicker("日期", selection: $date, displayedComponents: .date)
                TextField("备注", text: $note)
            }
            .navigationTitle(existing == nil ? "记一笔" : "编辑账单")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let amount = Double(amountText) ?? 0
                        guard amount > 0 else { return }
                        let item = TransactionItem(
                            id: existing?.id ?? UUID(),
                            type: type,
                            amount: amount,
                            category: category,
                            payment: payment,
                            date: date,
                            note: note
                        )
                        onSave(item)
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let e = existing {
                    type = e.type
                    amountText = String(format: "%.2f", e.amount)
                    category = e.category
                    payment = e.payment
                    date = e.date
                    note = e.note
                }
            }
            .onChange(of: type) { _, newType in
                let options = Categories.list(for: newType)
                if !options.contains(category) {
                    category = options[0]
                }
            }
        }
    }
}
