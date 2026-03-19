//
//  LebensbereicheView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 18.08.2024.
//

import SwiftUI
import SwiftData

struct LebensbereicheView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var refresh = false
    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    
    @State private var small : Bool = UIDevice.current.userInterfaceIdiom == .phone && Axis.Set.horizontal == .horizontal
   
    
    var body: some View {
        
        let cols = [GridItem(.adaptive(minimum: 200))]
        NavigationStack {
            // if small { Text("small") } else {Text("not small")}
            ScrollView {
                LazyVGrid(columns: cols, alignment: .leading, spacing: 10) {
                    ForEach(0..<9) {lebensbereich in
                        subLebensbereichView(lebensbereich: lebensbereich)
                        
                    }
                    //.frame(maxWidth:.infinity, alignment: .top)
                    .navigationTitle( "Lebensbereiche")
                    
                }
                .padding()
                .toolbar{
                    Button("", systemImage: "arrow.clockwise") {
                        refresh.toggle()
                    }
                    Button("", systemImage: "plus") {
                        newVorhaben = VorhabenModel()
                        modelContext.insert(newVorhaben)
                        addStandardAufgaben(Vorhaben: newVorhaben)
                        isNewVorhaben = true
                        refresh.toggle()
                    }
                }
                .id(refresh)
            }
            .sheet(isPresented: $isNewVorhaben){
                ModernVorhabenEditor(Vorhaben: newVorhaben, isNew: true)
            }
            .onAppear(){
                refresh.toggle()
            }
            
        }
    }
}

struct subLebensbereichView : View{
    @Environment(\.modelContext) private var modelContext
    let lebensbereich: Int
    
    private let sortDescriptors = [ SortDescriptor(\VorhabenModel.priority, order: .reverse) ]
    private var Vorhabens: [VorhabenModel] {
        let predicate = #Predicate<VorhabenModel> { Vorhaben in
            Vorhaben.lebensbereich == lebensbereich}
        let fetch = FetchDescriptor(predicate: predicate, sortBy: sortDescriptors)
        return try! modelContext.fetch(fetch)
    }
    
    var body: some View {
        VStack (alignment: .leading){
            if Vorhabens.count > 0 {
                HStack{
                    Text( Lebensbereiche[lebensbereich]! )
                        .font(.title2)
                       .fontWeight(.semibold)
                       .foregroundColor(LebensbereicheColor[lebensbereich])
                    Text("(\(Vorhabens.count))")
                        .foregroundColor(LebensbereicheColor[lebensbereich])
                    Spacer()
                }
                ForEach(Vorhabens){ Vorhaben in
                    NavigationLink(destination: ModernVorhabenEditor(Vorhaben: Vorhaben) ) {
                        Label( Vorhaben.bezeichnung,  systemImage: Vorhaben.viewIcon)
                            .fontWeight(Vorhaben.priority > 2 ? .bold : .regular)
                            .foregroundColor(Vorhaben.viewColor)
                     //       .padding(2)
                    }
                }
                
            } else {
                HStack{
                    
                    Text(Lebensbereiche[lebensbereich]! )
                        .font(.title2)
                        .foregroundColor(LebensbereicheColor[lebensbereich])
                        .fontWeight(.thin)
                    Text(" -")
                        .foregroundColor(LebensbereicheColor[lebensbereich])
                        .fontWeight(.thin)
                    Spacer()
                }
            }
            Spacer()
                
        }
        .padding(4)
        .border(LebensbereicheColor[lebensbereich]!)
        .background(LebensbereicheColor[lebensbereich]?.opacity(0.1).shadow(radius: 3))
        
        
        
    }
    
}



#Preview {
    
    LebensbereicheView()
        .modelContainer(VorhabenModel.preview)
}
