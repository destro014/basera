import Foundation

enum NotificationType: String, CaseIterable, Identifiable, Codable {
    case interestReceived
    case interestAccepted
    case interestRejected
    case agreementReady
    case agreementSigned
    case billGenerated
    case paymentDueReminder
    case paymentReceived
    case moveOutRequest
    case reviewReminder

    var id: String { rawValue }

    var title: String {
        switch self {
        case .interestReceived: "New interest received"
        case .interestAccepted: "Interest accepted"
        case .interestRejected: "Interest not accepted"
        case .agreementReady: "Agreement ready to review"
        case .agreementSigned: "Agreement signed"
        case .billGenerated: "Monthly bill generated"
        case .paymentDueReminder: "Payment due reminder"
        case .paymentReceived: "Payment received"
        case .moveOutRequest: "Move-out request"
        case .reviewReminder: "Review reminder"
        }
    }

    var systemImageName: String {
        switch self {
        case .interestReceived: "person.crop.circle.badge.questionmark"
        case .interestAccepted: "checkmark.seal"
        case .interestRejected: "xmark.seal"
        case .agreementReady: "doc.text"
        case .agreementSigned: "signature"
        case .billGenerated: "doc.badge.plus"
        case .paymentDueReminder: "calendar.badge.exclamationmark"
        case .paymentReceived: "indianrupeesign.circle"
        case .moveOutRequest: "door.left.hand.open"
        case .reviewReminder: "star.bubble"
        }
    }
}

enum NotificationAudience: String, Codable {
    case renter
    case owner
    case both
}

struct AppNotification: Identifiable, Equatable {
    let id: String
    let userID: String
    let audience: NotificationAudience
    let type: NotificationType
    let title: String
    let message: String
    let createdAt: Date
    var readAt: Date?
    let route: NotificationRoute
    let metadata: [String: String]

    var isUnread: Bool { readAt == nil }
}

struct NotificationBadgeState: Equatable {
    var unreadCount: Int

    static let empty = NotificationBadgeState(unreadCount: 0)
}

struct PushNotificationPayload {
    let id: String
    let userID: String
    let type: NotificationType
    let title: String
    let message: String
    let route: NotificationRoute
    let metadata: [String: String]
    let createdAt: Date
}

enum NotificationRoute: Hashable, Codable, Identifiable {
    case interests(listingID: String?)
    case agreement(agreementID: String?)
    case billing(invoiceID: String?)
    case payments(invoiceID: String?)
    case moveOut(tenancyID: String?)
    case review(tenancyID: String?)

    var id: String {
        switch self {
        case .interests(let listingID): "interests-\(listingID ?? "none")"
        case .agreement(let agreementID): "agreement-\(agreementID ?? "none")"
        case .billing(let invoiceID): "billing-\(invoiceID ?? "none")"
        case .payments(let invoiceID): "payments-\(invoiceID ?? "none")"
        case .moveOut(let tenancyID): "moveout-\(tenancyID ?? "none")"
        case .review(let tenancyID): "review-\(tenancyID ?? "none")"
        }
    }

    var destinationLabel: String {
        switch self {
        case .interests: "Open interests"
        case .agreement: "Open agreement"
        case .billing: "Open billing"
        case .payments: "Open payments"
        case .moveOut: "Open move-out"
        case .review: "Open reviews"
        }
    }
}
