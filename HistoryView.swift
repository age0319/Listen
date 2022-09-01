//
//  HistoryView.swift
//  Listen
//
//  Created by nokkun on 2022/01/20.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Song.time, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Song>
    var dateFormate: DateFormatter{
        let df = DateFormatter()
        df.dateFormat = "yyyy年MM月dd日 HH時mm分"
        return df
    }
    var body: some View {
        List {
            ForEach(items) { item in
                HStack{
                    AsyncImage(url: item.artURL) { image in
                        image
                            .resizable()
                            .frame(width: 60, height: 60)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.5))
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)
                            .redacted(reason: .privacy)
                    }
                    VStack {
                        if let title = item.title{
                            Text(title)
                        }
                        
                        if let artist = item.artist{
                            Text(artist)
                        }
                        
                        if let time = item.time{
                            Text(dateFormate.string(from: time))
                                .font(.footnote)
                        }
                    }
                    Spacer()
                }
            }.onDelete(perform: deleteItems)
        }
        .navigationTitle("楽曲履歴")
    }
    
    private func deleteItems(offsets: IndexSet) {
            for index in offsets {
                viewContext.delete(items[index])
            }
            try? viewContext.save()
        }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .preferredColorScheme(.dark)
    }
}
