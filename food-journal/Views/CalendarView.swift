import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [JournalEntry]

    @State private var selectedDate: Date? = nil
    @State private var showAddEntry = false
    @State private var showPastModal = false
    @State private var showEntries = false

    private let today = Calendar.current.startOfDay(for: Date())
    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Spacer()
                    Button(action: { showAddEntry = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                DateLabel(date: today)
                    .padding(.top, 4)

                Spacer().frame(height: 32)

                MonthCalendar(
                    entries: allEntries,
                    today: today,
                    onTap: handleDateTap
                )
                .padding(.horizontal, 20)

                Spacer()
            }

            if showAddEntry {
                AddEntryView(isPresented: $showAddEntry)
                    .zIndex(10)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showAddEntry)
            }

            if showPastModal {
                PastDateModal(isPresented: $showPastModal) {
                    showAddEntry = true
                }
                .zIndex(10)
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showPastModal)
            }
        }
        .fullScreenCover(isPresented: $showEntries) {
            if let date = selectedDate {
                let dayEntries = entries(for: date)
                ViewEntriesView(entries: dayEntries, date: date, isPresented: $showEntries)
            }
        }
    }

    private func handleDateTap(_ date: Date) {
        let day = calendar.startOfDay(for: date)
        if day == today {
            let dayEntries = entries(for: day)
            if dayEntries.isEmpty {
                showAddEntry = true
            } else {
                selectedDate = day
                showEntries = true
            }
        } else if day < today {
            let dayEntries = entries(for: day)
            if dayEntries.isEmpty {
                showPastModal = true
            } else {
                selectedDate = day
                showEntries = true
            }
        }
        // future dates: do nothing
    }

    private func entries(for date: Date) -> [JournalEntry] {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return allEntries.filter { $0.date >= start && $0.date < end }
            .sorted { $0.createdAt < $1.createdAt }
    }
}

struct MonthCalendar: View {
    let entries: [JournalEntry]
    let today: Date
    let onTap: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    private var daysInMonth: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: today)
        let firstOfMonth = calendar.date(from: comps)!
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!

        var days: [Date?] = Array(repeating: nil, count: weekdayOfFirst)
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
            days.append(date)
        }
        // pad to complete grid
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private var todayColumnIndex: Int {
        calendar.component(.weekday, from: today) - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(weekdaySymbols.indices, id: \.self) { i in
                    Text(weekdaySymbols[i])
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(i == todayColumnIndex ? Color.red : Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 8)

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(daysInMonth.indices, id: \.self) { i in
                    if let date = daysInMonth[i] {
                        DayCell(
                            date: date,
                            today: today,
                            thumbnail: thumbnail(for: date),
                            hasEntries: hasEntries(for: date)
                        )
                        .onTapGesture { onTap(date) }
                    } else {
                        Color.clear.frame(height: cellSize)
                    }
                }
            }
        }
    }

    private var cellSize: CGFloat { (UIScreen.main.bounds.width - 40) / 7 }

    private func hasEntries(for date: Date) -> Bool {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return entries.contains { $0.date >= start && $0.date < end }
    }

    private func thumbnail(for date: Date) -> UIImage? {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return entries
            .filter { $0.date >= start && $0.date < end }
            .sorted { $0.createdAt < $1.createdAt }
            .first?.image
    }
}

struct DayCell: View {
    let date: Date
    let today: Date
    let thumbnail: UIImage?
    let hasEntries: Bool

    @State private var pressed = false

    private let calendar = Calendar.current

    private var isToday: Bool { calendar.startOfDay(for: date) == today }
    private var isFuture: Bool { calendar.startOfDay(for: date) > today }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width

            ZStack {
                if let img = thumbnail {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else if isToday {
                    Circle().fill(Color.red)
                } else if isFuture {
                    Circle()
                        .fill(Color.clear)
                        .overlay(Circle().stroke(Color(UIColor.systemGray4), lineWidth: 1.5))
                } else {
                    Circle().fill(Color.primary)
                }

            }
            .frame(width: size, height: size)
            .scaleEffect(pressed ? 0.88 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                pressed = pressing
            }, perform: {})
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
