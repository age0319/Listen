//
//  ContentView.swift
//  Listen
//
//  Created by nokkun on 2022/01/19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = ViewModel()

#if targetEnvironment(simulator)
    //Only For Simulator
    var sample = SampleInsert()
#endif
    
    var body: some View {
        
        NavigationView{
            
            ZStack {
                AsyncImage(url: viewModel.shazamMedia.albumArtURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 10, opaque: true)
                        .opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                } placeholder: {
                    EmptyView()
                }
                VStack(alignment: .center) {
                    Spacer()
                    AsyncImage(url: viewModel.shazamMedia.albumArtURL) { image in
                        image
                            .resizable()
                            .frame(width: 300, height: 300)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple.opacity(0.5))
                            .frame(width: 300, height: 300)
                            .cornerRadius(10)
                            .redacted(reason: .privacy)
                    }
                    VStack(alignment: .center) {
                        Text(viewModel.shazamMedia.title ?? "Title")
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        Text(viewModel.shazamMedia.artistName ?? "Artist Name")
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }.padding()
                    Spacer()
                    Button(action: {
                        viewModel.startListening(context: viewContext)
                    }){
                        Text("???????????????????????????")
                            .frame(width: 300)
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .shadow(radius: 4)
                        .alert("???????????????", isPresented: $viewModel.isRecording) {
                            Button("????????????") {
                                // ??????????????????????????????????????????
                                viewModel.stopListening()
                            }
                        } message: {
                            Text("???????????????????????????????????????????????????????")
                        }
                        .alert("????????????????????????????????????????????????????????????", isPresented: $viewModel.showPrivacyConfirm) {
                            Button("OK") {
                                // ??????????????????????????????????????????
                                viewModel.showPrivacyConfirm = false
                            }
                        } message: {
                            Text("????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????")
                        }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HistoryView()){
                        Image(systemName: "info.circle")
                    }
                }
                
#if targetEnvironment(simulator)
  // your simulator code
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.shazamMedia = sample.doSampleSet(context: viewContext)
                    } label: {
                        Text("-")
                    }
                }
#else
  // your real device code
#endif
                
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .preferredColorScheme(.dark)
    }
}
