import SwiftUI

struct ViewEntriesView: View {
    let entries: [JournalEntry]
    let date: Date
    @Binding var isPresented: Bool
    @State private var currentIndex = 0

    private var displayDate: Date { date }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(UIColor.systemGray6).ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        if let img = entry.image {
                            CardView(image: img, isTop: index == currentIndex)
                                .offset(y: CGFloat(index - currentIndex) * 8)
                                .scaleEffect(index == currentIndex ? 1 : 0.96 - CGFloat(abs(index - currentIndex)) * 0.02)
                                .zIndex(Double(entries.count - abs(index - currentIndex)))
                                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentIndex)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.width)
                .padding(.top, 60)
                .contentShape(Rectangle())
                .onTapGesture {
                    if entries.count > 1 {
                        currentIndex = (currentIndex + 1) % entries.count
                    }
                }

                if entries.count > 1 {
                    Text("tap to see all entries")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.top, 12)
                }

                Spacer()

                DateLabel(date: displayDate)
                    .padding(.bottom, 32)
            }

            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
            }
            .padding(.top, 16)
            .padding(.trailing, 20)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

private struct CardView: View {
    let image: UIImage
    let isTop: Bool

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 16, y: 6)
    }
}

struct DateLabel: View {
    let date: Date

    private var day: String {
        let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: date)
    }
    private var month: String {
        let f = DateFormatter(); f.dateFormat = "MMMM"; return f.string(from: date).uppercased()
    }
    private var year: String {
        let f = DateFormatter(); f.dateFormat = "yyyy"; return f.string(from: date)
    }
    private var weekday: String {
        let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: date)
    }

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: -4) {
                Text(day)
                    .font(.system(size: 120, weight: .black))
                    .foregroundStyle(.primary)
                Text(month)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.primary)
                Text(year)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(weekday)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 28)
    }
}
