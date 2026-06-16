import Foundation
import SwiftData
import UIKit

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var imagePath: String
    var createdAt: Date

    init(date: Date, imagePath: String) {
        self.id = UUID()
        self.date = date
        self.imagePath = imagePath
        self.createdAt = Date()
    }

    var image: UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imagePath)
        return UIImage(contentsOfFile: url.path)
    }
}

extension JournalEntry {
    static func save(image: UIImage, for date: Date, context: ModelContext) {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        let entry = JournalEntry(date: date, imagePath: filename)
        context.insert(entry)
        try? context.save()
    }
}
