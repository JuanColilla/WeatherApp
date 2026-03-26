import Foundation

enum AIQuoteState: Equatable, Sendable {
    case idle
    case generating
    case generated(String)
    case unavailable(String)
}
