import Foundation

protocol PaymentGatewayServiceProtocol: Sendable {
    func createIntent(paymentID: String, method: PaymentRecord.Method, amount: Decimal) async throws -> PaymentGatewayIntent
}
