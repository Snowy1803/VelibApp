//
//  LocationModal.swift
//  Velib
//
//  Created by Emil Pedersen on 14/06/2022.
//

import SwiftUI

struct LocationModal: View {
    
    var velib: VelibLocation
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Vélos disponibles")
                    Spacer()
                    Text("\(velib.fields.numbikesavailable)")
                }
                HStack {
                    Image(systemName: "bolt.circle")
                    Text("Vélos électriques")
                    Spacer()
                    Text("\(velib.fields.ebike)")
                }
                HStack {
                    Image(systemName: "bolt.slash.circle")
                    Text("Vélos mécaniques")
                    Spacer()
                    Text("\(velib.fields.mechanical)")
                }
                HStack {
                    Text("Emplacements vides")
                    Spacer()
                    Text("\(velib.fields.numdocksavailable)")
                }
                HStack {
                    Text("Capacité")
                    Spacer()
                    Text("\(velib.fields.capacity)")
                }
            } footer: {
                Text("\(velib.fields.name), \(velib.fields.nomArrondissementCommunes)")
            }
        }
        #if os(iOS)
        .navigationTitle(velib.fields.name)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct LocationModal_Previews: PreviewProvider {
    static var previews: some View {
        LocationModal(velib: VelibLocation(fields: VelibFields(name: "Some name", stationcode: "007", numbikesavailable: 20, ebike: 19, mechanical: 1, numdocksavailable: 5, capacity: 25, nomArrondissementCommunes: "Commune", dist: "100", coordonneesGeo: [2, 25])))
    }
}
