//
//  SOSView.swift
//  SoloPapá - Emergency SOS view
//
//  Crisis support and emergency contacts
//

import SwiftUI

struct SOSView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Emergencia")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Si necesitas ayuda inmediata, presiona uno de los botones de abajo")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Emergency buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Emergency services placeholder
                        print("Llamar al 911")
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Llamar al 911")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Crisis text line placeholder
                        print("Línea de Crisis")
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Línea de Crisis (Texto)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // Mental health support placeholder
                        print("Línea de Salud Mental")
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Línea de Salud Mental (988)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("Tu seguridad es lo más importante")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("SOS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
