//
//  HandwritingCanvas.swift
//  JustDad - Handwriting Canvas Component
//
//  Componente para escritura a mano obligatoria en técnicas de liberación
//

import SwiftUI
import PencilKit

struct HandwritingCanvas: View {
    @Binding var handwrittenContent: String
    @State private var canvasView = PKCanvasView()
    @State private var isWriting = false
    @State private var hasWritten = false
    @State private var showingClearAlert = false
    let prompt: String
    let isRequired: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "pencil.and.outline")
                        .foregroundColor(.blue)
                    Text("Escritura a Mano")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text(prompt)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: hasWritten ? "checkmark.circle.fill" : "pencil.circle")
                        .foregroundColor(hasWritten ? .green : .blue)
                    Text(hasWritten ? "Escritura completada" : "Escritura opcional")
                        .font(.caption)
                        .foregroundColor(hasWritten ? .green : .blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
            
            // Canvas
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if canvasView.drawing.strokes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Escribe aquí con tu dedo o lápiz")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Text("La escritura a mano es opcional pero recomendada - activa diferentes áreas del cerebro y facilita la conexión emocional")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                PKCanvasViewRepresentable(canvasView: $canvasView)
                    .onChange(of: canvasView.drawing.strokes.count) { _ in
                        checkWritingStatus()
                    }
            }
            .frame(height: 300)
            
            // Controls
            HStack(spacing: 16) {
                Button(action: clearCanvas) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                        Text("Limpiar")
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                
                Spacer()
                
                Button(action: convertToText) {
                    HStack(spacing: 8) {
                        Image(systemName: "textformat")
                        Text("Convertir a Texto")
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .disabled(canvasView.drawing.strokes.isEmpty)
            }
            
            // Text Preview
            if !handwrittenContent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contenido escrito:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(handwrittenContent)
                        .font(.body)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
            }
        }
        .alert("Limpiar Canvas", isPresented: $showingClearAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Limpiar", role: .destructive) {
                clearCanvasConfirmed()
            }
        } message: {
            Text("¿Estás seguro de que quieres limpiar todo el contenido escrito?")
        }
    }
    
    private func checkWritingStatus() {
        hasWritten = !canvasView.drawing.strokes.isEmpty
        isWriting = !canvasView.drawing.strokes.isEmpty
    }
    
    private func clearCanvas() {
        if !canvasView.drawing.strokes.isEmpty {
            showingClearAlert = true
        }
    }
    
    private func clearCanvasConfirmed() {
        canvasView.drawing = PKDrawing()
        handwrittenContent = ""
        hasWritten = false
        isWriting = false
    }
    
    private func convertToText() {
        // En una implementación real, aquí usarías OCR para convertir el dibujo a texto
        // Por ahora, simulamos la conversión
        handwrittenContent = "Contenido convertido desde escritura a mano (simulado)"
        hasWritten = true
    }
}

// MARK: - PKCanvasView Representable
struct PKCanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 2)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update if needed
    }
}

#Preview {
    HandwritingCanvas(
        handwrittenContent: .constant(""),
        prompt: "Escribe aquí tus pensamientos y emociones sobre lo que necesitas liberar...",
        isRequired: false
    )
    .padding()
}
