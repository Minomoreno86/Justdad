//
//  SOSView.swift
//  SoloPapá - Emergency SOS view
//
//  Crisis support and emergency contacts
//

import SwiftUI

struct SOSView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingCallAlert = false
    @State private var showingTextAlert = false
    @State private var showingMentalHealthAlert = false
    @State private var showingEmergencyContacts = false
    @State private var showingCalmingExercises = false
    @State private var emergencyNumber = "911"
    @State private var crisisTextNumber = "741741"
    @State private var mentalHealthNumber = "988"
    
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
                    // Emergency Services
                    Button(action: {
                        makePhoneCall(number: emergencyNumber)
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Llamar al \(emergencyNumber)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Crisis Text Line
                    Button(action: {
                        sendCrisisText()
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
                    
                    // Mental Health Support
                    Button(action: {
                        makePhoneCall(number: mentalHealthNumber)
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("Línea de Salud Mental (\(mentalHealthNumber))")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Additional Support Options
                    VStack(spacing: 12) {
                        Button(action: {
                            showingEmergencyContacts = true
                        }) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("Contactos de Emergencia")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            showingCalmingExercises = true
                        }) {
                            HStack {
                                Image(systemName: "wind")
                                Text("Ejercicios de Calma")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
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
            .sheet(isPresented: $showingEmergencyContacts) {
                EmergencyContactsView()
            }
            .sheet(isPresented: $showingCalmingExercises) {
                CalmingExercisesView()
            }
            .alert("¿Llamar al \(emergencyNumber)?", isPresented: $showingCallAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Llamar", role: .destructive) {
                    makePhoneCall(number: emergencyNumber)
                }
            } message: {
                Text("Se abrirá la aplicación de teléfono para realizar la llamada de emergencia.")
            }
            .alert("¿Enviar mensaje de crisis?", isPresented: $showingTextAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Enviar", role: .destructive) {
                    sendCrisisText()
                }
            } message: {
                Text("Se abrirá la aplicación de mensajes para contactar la línea de crisis.")
            }
            .alert("¿Llamar a la línea de salud mental?", isPresented: $showingMentalHealthAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Llamar", role: .destructive) {
                    makePhoneCall(number: mentalHealthNumber)
                }
            } message: {
                Text("Se abrirá la aplicación de teléfono para contactar la línea de salud mental.")
            }
        }
    }
    
    // MARK: - Emergency Functions
    private func makePhoneCall(number: String) {
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendCrisisText() {
        if let url = URL(string: "sms:\(crisisTextNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Emergency Contacts View
struct EmergencyContactsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Contactos de Emergencia")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Aquí puedes agregar contactos de emergencia como familiares, amigos, abogados o terapeutas.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
                
                Text("Funcionalidad en desarrollo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Contactos de Emergencia")
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

// MARK: - Calming Exercises View
struct CalmingExercisesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Ejercicios de Calma")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Técnicas de respiración y relajación para momentos de crisis.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
                
                Text("Funcionalidad en desarrollo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Ejercicios de Calma")
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

