import SwiftUI

struct PastDateModal: View {
    @Binding var isPresented: Bool
    var onAddToday: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(alignment: .leading, spacing: 0) {
                Text("Oop-")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.bottom, 6)

                Text("You can't go back in time unfortunately, but you definitely can stay in the present. Would you like to add an entry for today instead?")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 28)

                Button(action: {
                    isPresented = false
                    onAddToday()
                }) {
                    Text("Sure!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 10)

                Button(action: { isPresented = false }) {
                    Text("Nope, I'm Good")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
            )
            .padding(.horizontal, 32)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }
}
