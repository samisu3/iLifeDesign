//
//  ExperimentTitleView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 10.08.2024.
//

import SwiftUI
import SwiftData

struct ExperimentTitleView: View {
    let experiment: ExperimentModel
    let devicePhone = UIDevice.current.userInterfaceIdiom == .phone
    @State private var portrait = UIDevice.current.orientation == .portrait
    
    var body: some View {
        Text("Device Phone \(devicePhone) und portrait \(UIDevice.current.orientation)")
        HStack{
            Image(systemName: experiment.viewIcon)
                .foregroundColor(experiment.viewColor)
            
            if !(devicePhone && portrait) {
                Text(experiment.bezeichnung)
                    .fontWeight(experiment.priority > 1 ? .semibold : .regular)
                    .foregroundStyle(experiment.viewColor)
            }
            Text(experiment.viewpriority)
                .foregroundStyle(experiment.priority > 1 ? Color.red : Color.gray)
        }
    }
    
}

#Preview {
    let container = ExperimentModel.preview
    let experiments = try! container.mainContext.fetch(
        FetchDescriptor<ExperimentModel>(predicate: #Predicate { experiment in
            experiment.bezeichnung == "iLifeDesign"
        }))
    
    return NavigationStack {
        ExperimentTitleView(experiment: experiments[0])
    }
}
