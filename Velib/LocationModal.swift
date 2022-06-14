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
            HStack {
                Text("Vélos disponibles")
                Spacer()
                Text("\(velib.fields.numbikesavailable)")
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
        }.navigationTitle(velib.fields.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationModal_Previews: PreviewProvider {
    static var previews: some View {
        LocationModal(velib: VelibLocation(fields: VelibFields(name: "Some name", stationcode: "007", numbikesavailable: 20, numdocksavailable: 5, capacity: 25, nomArrondissementCommunes: "Commune", dist: "100", coordonneesGeo: [2, 25])))
    }
}
