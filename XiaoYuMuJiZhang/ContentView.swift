import SwiftUI

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var month = Date()
    @State private var showingAdd = false
    @State private var editing: TransactionItem?
    @State private var search = ""

    var monthItems: [TransactionItem] {
        let base = store.items(inMonthOf: month)
        if search.isEmpty { return base }
        return base.filter { $0.category.contains(search) || $0.note.contains(search) }
    }
    var income: Double { monthItems.filter{$0.type==.income}.reduce(0){$0+$1.amount} }
    var expense: Double { monthItems.filter{$0.type==.expense}.reduce(0){$0+$1.amount} }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                List {
                    Section {
                        ForEach(monthItems) { item in
                            Button { editing = item } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.category).foregroundStyle(.primary)
                                        Text("\(item.note.isEmpty ? item.payment.rawValue : item.note) · \(item.date, format: .dateTime.month().day())")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("\(item.type == .expense ? "-" : "+")¥\(item.amount, specifier: "%.2f")")
                                        .foregroundStyle(item.type == .expense ? .primary : .green)
                                }
                            }
                        }
                        .onDelete { idx in idx.forEach { store.delete(monthItems[$0]) } }
                    } header: { Text("明细") }
                    Section("本月预算 ¥\(store.monthlyBudget, specifier: "%.0f")") {
                        ProgressView(value: min(expense, store.monthlyBudget), total: max(store.monthlyBudget, 1))
                        Text("已支出 ¥\(expense, specifier: "%.2f")，剩余 ¥\(max(store.monthlyBudget-expense,0), specifier: "%.2f")")
                            .font(.caption).foregroundStyle(.secondary)
                        HStack {
                            Button("预算 -500") { store.monthlyBudget = max(500, store.monthlyBudget-500) }
                            Spacer()
                            Button("预算 +500") { store.monthlyBudget += 500 }
                        }.font(.caption)
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
            .navigationTitle("小榆木记账")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill").font(.title3) }
                }
            }
            .sheet(isPresented: $showingAdd) { EditorView { store.add($0) } }
            .sheet(item: $editing) { item in
                EditorView(existing: item) { store.update($0) }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button { month = Calendar.current.date(byAdding: .month, value: -1, to: month)! } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(month, format: .dateTime.year().month()).font(.headline)
                Spacer()
                Button { month = Calendar.current.date(byAdding: .month, value: 1, to: month)! } label: { Image(systemName: "chevron.right") }
            }
            Text("本月结余").font(.caption).foregroundStyle(.secondary)
            Text("¥\(income-expense, specifier: "%.2f")").font(.largeTitle.bold())
            HStack(spacing: 24) {
                Text("收入 ¥\(income, specifier: "%.2f")").foregroundStyle(.green)
                Text("支出 ¥\(expense, specifier: "%.2f")")
            }.font(.subheadline)
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
                    ForEach(TxType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                TextField("金额", text: $amountText).keyboardType(.decimalPad)
                Picker("分类", selection: $category) {
                    ForEach(Categories.list(for: type), id: \.self) { Text($0).tag($0) }
                }
                Picker("支付方式", selection: $payment) {
                    ForEach(Payment.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                DatePicker("日期", selection: $date, displayedComponents: .date)
                TextField("备注", text: $note)
            }
            .navigationTitle(existing == nil ? "记一笔" : "编辑账单")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let amount = Double(amountText) ?? 0
                        guard amount > 0 else { return }
                        let item = TransactionItem(id: existing?.id ?? UUID(), type: type, amount: amount, category: category, payment: payment, date: date, note: note)
                        onSave(item); dismiss()
                    }
                }
            }
            .onAppear {
                if let e = existing {
                    type = e.type; amountText = String(format: "%.2f", e.amount); category = e.category; payment = e.payment; date = e.date; note = e.note
                }
            }
            .onChange(of: type) { _, newType in
                if !Categories.list(for: newType).contains(category) { category = Categories.list(for: newType).first! }
            }
        }
    }
}
