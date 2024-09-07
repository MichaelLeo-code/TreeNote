//
//  ContentView.swift
//  TreeNote
//
//  Created by Michael Leo on 07/09/2024.
//

import SwiftUI
import SwiftData


class Blob : Identifiable, ObservableObject {
    let id = UUID()
    @Published var offsetX : CGFloat = CGFloat.random(in: -15...15)
    @Published var offsetY : CGFloat = CGFloat.random(in: -15...15)
    @Published var color : Color = .pink
    
    func randomizePositions() {
            objectWillChange.send()
            offsetY = CGFloat.random(in: -15...15)
        }
}

class BlobTracker : ObservableObject {
    let id = UUID()
    @Published var blobs = [Blob]()
    static var colors: [Color] = [.pink, .blue, .yellow, .red, .teal]
    static var randomColor: Color {
            colors.randomElement() ?? .blue
        }
        
    init() {
        for i in 0..<3 {
            blobs.append(Blob())
            blobs[i].color = BlobTracker.randomColor
        }
    }
    
    func randomizePositions() {
        objectWillChange.send()
        for blob in blobs{
            blob.randomizePositions()
            blob.offsetX = CGFloat.random(in: -15...15)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject var tracker = BlobTracker()
    
    /// <#Description#>
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            VStack(content: {
                ZStack(content: {
                    ForEach(tracker.blobs) { blob in
                        RoundedRectangle(cornerRadius:10)
                            .fill(blob.color)
                            .blur(radius: 4.0)
                            .frame(maxWidth: 50, maxHeight: 100.0)
                            .offset(CGSize(width: blob.offsetX, height: blob.offsetY))
                    }
                    RoundedRectangle(cornerRadius:10)
                        .frame(maxWidth: 50, maxHeight: 100.0)
                })
                .frame(width: 300, height: 300)
                .drawingGroup()
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                        tracker.randomizePositions()
                        }
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 1.0)) {
                                tracker.randomizePositions()
                            }
                        }
                }
            })
        }
    }
    
    

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
