//
//  Payment.swift
//  ERA
//
//  Created by Siddharth Shakthivel Muthu Pandian on 14/04/2023.
//

import SwiftUI
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    private let productIds = ["com.mindcore.era.premium.yearly", "com.mindcore.era.premium.monthly"]

    @Published
    private(set) var products: [Product] = []
    private var productsLoaded = false
    
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    var hasUnlockedPremium: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }

    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            await transaction.finish()
            await self.updatePurchasedProducts()
        case let .success(.unverified(_, _)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
}

struct Payment: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var settings: UserPreferences
    
    @Environment(\.presentationMode) var testPresentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            ScrollView() {
                HStack {
                    Button {
                        testPresentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("arrow-left")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .invertOnDarkTheme()

                        Text("ERA Premium")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textCase(.uppercase)
                            .padding()
                    }
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                VStack {
                    Text("ERA Premium")
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textCase(.uppercase)
                        .padding()
                    
                    if purchaseManager.hasUnlockedPremium {
                        Text("Thank you for purchasing ERA premium!")
                            .foregroundColor(.black)
                            .invertOnDarkTheme()
                            .font(.system(size: 20, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(purchaseManager.products) { product in
                            Button {
                                _ = Task<Void, Never> {
                                    do {
                                        try await purchaseManager.purchase(product)
                                    } catch {
                                        print(error)
                                    }
                                }
                            } label: {
                                Text("\(product.displayName) - \(product.displayPrice)")
                                    .foregroundColor(.black)
                                    .invertOnDarkTheme()
                                    .font(.system(size: 16, weight: .semibold))
                            }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(10)
                                .padding()
                                .invertBackgroundOnDarkTheme(isBase: false)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: settings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                                )
                        }
                    }
                }
                
                Button {
                    Task {
                        do {
                            try await AppStore.sync()
                        } catch {
                            print(error)
                            
                            print(settings.isDarkMode)
                        }
                    }
                } label: {
                    Text("Reset")
                        .textCase(.uppercase)
                        .foregroundColor(.black)
                        .invertOnDarkTheme()
                        .padding()
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                    .invertBackgroundOnDarkTheme(isBase: false)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: settings.isDarkMode ? 0xAB9D96 : 0xF2EDE4, alpha: 1), lineWidth: 1)
                    )
                    .cornerRadius(10)
                    .frame(maxHeight: .infinity, alignment: .bottomLeading)
                    .padding()
                
            }
                .padding()
                .invertBackgroundOnDarkTheme(isBase: true)
                .edgesIgnoringSafeArea(.all)
                .task {
                    _ = Task<Void, Never> {
                        do {
                            try await purchaseManager.loadProducts()
                        } catch {
                            print(error)
                        }
                    }
                }
        }
            .invertBackgroundOnDarkTheme(isBase: true)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

