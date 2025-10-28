import SwiftUI

// MARK: - Main App
@main
struct WalletApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Models
struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let date: Date
    let type: TransactionType
}

enum TransactionType {
    case income
    case expense
}

// MARK: - Main View
struct ContentView: View {
    @State private var balance: Double = 0.0
    @State private var transactions: [Transaction] = []
    @State private var showAddMoney = false
    @State private var showTransactions = false
    @State private var isBalanceVisible = true
    @State private var cardOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Card
                        walletCard
                            .padding(.top, 20)
                        
                        // Quick Actions
                        quickActionsView
                        
                        // Recent Transactions
                        transactionsListView
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            
            // Add Money Sheet
            if showAddMoney {
                AddMoneyView(
                    isPresented: $showAddMoney,
                    onAdd: { amount in
                        addMoney(amount: amount)
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Wallet")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isBalanceVisible.toggle()
                }
            }) {
                Image(systemName: isBalanceVisible ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
    
    // MARK: - Wallet Card
    private var walletCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Total Balance")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("€")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                if isBalanceVisible {
                    Text(String(format: "%.2f", balance))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.opacity)
                } else {
                    Text("••••••")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isBalanceVisible)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .offset(y: cardOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    cardOffset = value.translation.height * 0.3
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        cardOffset = 0
                    }
                }
        )
    }
    
    // MARK: - Quick Actions
    private var quickActionsView: some View {
        HStack(spacing: 15) {
            QuickActionButton(
                icon: "plus.circle.fill",
                title: "Add Money",
                action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showAddMoney = true
                    }
                }
            )
            
            QuickActionButton(
                icon: "arrow.up.circle.fill",
                title: "Send",
                action: {}
            )
            
            QuickActionButton(
                icon: "arrow.down.circle.fill",
                title: "Request",
                action: {}
            )
        }
    }
    
    // MARK: - Transactions List
    private var transactionsListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !transactions.isEmpty {
                    Button(action: {}) {
                        Text("View All")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if transactions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No transactions yet")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 10) {
                    ForEach(transactions.prefix(5)) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
    }
    
    // MARK: - Functions
    private func addMoney(amount: Double) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            balance += amount
        }
        
        let transaction = Transaction(
            title: "Added Money",
            amount: amount,
            date: Date(),
            type: .income
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            transactions.insert(transaction, at: 0)
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(transaction.type == .income ? Color.white.opacity(0.15) : Color.white.opacity(0.1))
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: transaction.type == .income ? "arrow.down" : "arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(formatDate(transaction.date))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(transaction.type == .income ? "+" : "-")€\(String(format: "%.2f", transaction.amount))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.type == .income ? .white : .gray)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Add Money View
struct AddMoneyView: View {
    @Binding var isPresented: Bool
    let onAdd: (Double) -> Void
    
    @State private var amountText = ""
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissView()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 25) {
                    // Handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 10)
                    
                    // Title
                    Text("Add Money")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                    
                    // Amount Input
                    VStack(spacing: 15) {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("€")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("0.00", text: $amountText)
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 25)
                        
                        // Quick Amount Buttons
                        HStack(spacing: 10) {
                            ForEach([10.0, 50.0, 100.0, 500.0], id: \.self) { amount in
                                Button(action: {
                                    amountText = String(format: "%.0f", amount)
                                }) {
                                    Text("€\(Int(amount))")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.vertical, 20)
                    
                    // Add Button
                    Button(action: {
                        if let amount = Double(amountText), amount > 0 {
                            onAdd(amount)
                            dismissView()
                        }
                    }) {
                        Text("Add Money")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white)
                            )
                    }
                    .padding(.horizontal, 25)
                    .disabled(amountText.isEmpty || Double(amountText) == nil || Double(amountText)! <= 0)
                    .opacity((amountText.isEmpty || Double(amountText) == nil || Double(amountText)! <= 0) ? 0.5 : 1.0)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(white: 0.1))
                        .ignoresSafeArea()
                )
                .offset(y: offset)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                offset = 0
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            offset = UIScreen.main.bounds.height
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}