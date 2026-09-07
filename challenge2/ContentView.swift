import SwiftUI

struct PhotoItem: Identifiable {
    let id = UUID()
    let emoji: String
}

extension PhotoItem {
    static let sampleItems: [PhotoItem] = (0..<60).map { _ in
        PhotoItem(
            emoji: String(UnicodeScalar(0x1F200 + Int.random(in: 0...79))!)
        )
    }
}

struct PhotoCell: View {
    let item: PhotoItem
    private let cellSize: CGFloat = 75

    var body: some View {
        ZStack {
            Text(item.emoji)
                .font(.system(size: 65))
                .frame(width: cellSize, height: cellSize)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        }
        .frame(width: cellSize * 2.5, height: cellSize * 2.5)
        .background(Color(.blue))
        .cornerRadius(12)
    }
}

struct PrinterestGrid: View {
    let items: [PhotoItem]
    let columns: Int
    var spacing: CGFloat = 2
    var gradientColors: [Color] = [
        Color.pink.opacity(0.5), Color.blue.opacity(0.5),
        Color.purple.opacity(0.5),
    ]

    var body: some View {
        let gridColumns = Array(
            repeating: GridItem(.flexible(), spacing: spacing),
            count: columns
        )

        return ScrollView {
            LazyVGrid(columns: gridColumns, spacing: spacing) {
                ForEach(items) { item in
                    PhotoCell(item: item)
                }
            }
            .padding(spacing)
        }
    }
}

struct ContentView: View {
    @State private var items = PhotoItem.sampleItems
    @State private var inputEmoji: String = ""
    @State private var selectedItemID: PhotoItem.ID?
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false

    var filteredItems: [PhotoItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.emoji.contains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if isSearchActive {
                    HStack {
                        TextField("Search emojis...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Cancel") {
                            searchText = ""
                            withAnimation { isSearchActive = false }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                HStack {
                    TextField("Enter emoji or text...", text: $inputEmoji)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Add") {
                        if !inputEmoji.isEmpty {
                            let newItem = PhotoItem(emoji: inputEmoji)
                            items.insert(newItem, at: 0)
                            inputEmoji = ""

                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                HStack {
                    Picker("Target Item", selection: $selectedItemID) {
                        Text("Choose emoji").tag(PhotoItem.ID?.none)
                        ForEach(items) { item in
                            Text(item.emoji).tag(Optional(item.id))
                        }
                    }
                    .pickerStyle(.menu)
                    Spacer()

                    Button("Move to Top") {
                        if let id = selectedItemID,
                            let index = items.firstIndex(where: { $0.id == id })
                        {
                            withAnimation {
                                let item = items.remove(at: index)
                                items.insert(item, at: 0)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .disabled(selectedItemID == nil)

                    Button("Remove") {
                        if let id = selectedItemID,
                            let index = items.firstIndex(where: { $0.id == id })
                        {
                            withAnimation {
                                items.remove(at: index)
                                selectedItemID = nil
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(selectedItemID == nil)
                }
                .padding(.horizontal)
                ZStack {
                    PrinterestGrid(
                        items: filteredItems,
                        columns: 2,
                        spacing: 10
                    )
                }
            }
            .navigationTitle("Printerest Grid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { isSearchActive.toggle() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
