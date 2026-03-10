import Foundation

struct Listing: Identifiable, Equatable {
    let id: String
    let title: String
    let approximateLocation: String
    let monthlyRent: Int
    let bedroomCount: Int
}
