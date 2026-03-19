//
//  PathView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 17.08.2024.
//

import SwiftUI

struct PathView: View {
    var body: some View {
        Image(systemName: "arrowshape.right.fill")
           
            .resizable()
            .frame(width: 100, height: 200)
            .rotationEffect(.degrees(90))
            .foregroundColor(.blue)
    }
}

#Preview {
    PathView()
}
