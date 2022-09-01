//
//  SampleInsert.swift
//  Listen
//
//  Created by nokkun on 2022/01/20.
//

import Foundation
import CoreData

class SampleInsert {
    let titles = ["No Sense","Grenade","Castle On The Hill"]
    let artists = ["ジャスティン・ビーバー","ブルーノ・マーズ","エド・シーラン"]
    let urls = [
        "",
        "",
        ""]
        
    func doSampleSet(context:NSManagedObjectContext) -> ShazamMedia {
        for i in 0..<titles.count{
            let newItem = Song(context: context)
            newItem.artist = artists[i]
            newItem.title = titles[i]
            newItem.artURL = URL(string: urls[i])
            newItem.time = Date()
            
            try? context.save()
        }
        
        let sm = ShazamMedia(title: titles[0],
                             subtitle: "Subtitle...",
                             artistName: artists[0],
                             albumArtURL: URL(string: urls[0]),
                             genres: ["Pop"])
        return sm
    }
}
