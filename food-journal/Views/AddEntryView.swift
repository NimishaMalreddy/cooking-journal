import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    var onAdded: (() -> Void)?

    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(alignment: .leading, spacing: 0) {
                Text("Add an entry")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.bottom, 6)

                Text("What's cooking in your kitchen today?")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 28)

                Button(action: { showCamera = true }) {
                    Text("Take Photo")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 10)

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Text("Upload Photo")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 10)

                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
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
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                saveEntry(image: image)
                showCamera = false
            } onCancel: {
                showCamera = false
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    saveEntry(image: image)
                }
            }
        }
    }

    private func saveEntry(image: UIImage) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        JournalEntry.save(image: image, for: Date(), context: modelContext)
        isPresented = false
        onAdded?()
    }
}
