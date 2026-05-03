import Foundation

enum Priority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct Task: Codable {
    let id: Int
    var title: String
    var description: String
    var isCompleted: Bool
    var category: String
    var priority: Priority
}