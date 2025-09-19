import SwiftUI
import VisionKit
import Vision
#if os(iOS)
import UIKit
#endif

#if os(iOS)
struct ReceiptScannerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onReceiptScanned: (ReceiptData) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: ReceiptScannerView
        
        init(_ parent: ReceiptScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                parent.isPresented = false
                return
            }
            
            // Procesar la primera página del escaneo
            let page = scan.imageOfPage(at: 0)
            processReceiptImage(page) { receiptData in
                DispatchQueue.main.async {
                    self.parent.onReceiptScanned(receiptData)
                    self.parent.isPresented = false
                }
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.isPresented = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Error scanning document: \(error)")
            parent.isPresented = false
        }
        
        private func processReceiptImage(_ image: UIImage, completion: @escaping (ReceiptData) -> Void) {
            guard let cgImage = image.cgImage else {
                completion(ReceiptData())
                return
            }
            
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion(ReceiptData())
                    return
                }
                
                let extractedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                let receiptData = self.extractReceiptData(from: extractedText, image: image)
                completion(receiptData)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Error performing OCR: \(error)")
                completion(ReceiptData())
            }
        }
        
        private func extractReceiptData(from text: String, image: UIImage) -> ReceiptData {
            var receiptData = ReceiptData()
            receiptData.rawText = text
            receiptData.originalImage = image
            
            // Extraer monto usando regex para patrones comunes
            let amountPatterns = [
                "\\$?([0-9,]+\\.[0-9]{2})",  // $123.45
                "Total[\\s:]*\\$?([0-9,]+\\.[0-9]{2})",  // Total: $123.45
                "Amount[\\s:]*\\$?([0-9,]+\\.[0-9]{2})",  // Amount: $123.45
                "([0-9,]+\\.[0-9]{2})\\s*USD",  // 123.45 USD
            ]
            
            for pattern in amountPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(location: 0, length: text.utf16.count)
                    if let match = regex.firstMatch(in: text, options: [], range: range) {
                        if let amountRange = Range(match.range(at: 1), in: text) {
                            let amountString = String(text[amountRange]).replacingOccurrences(of: ",", with: "")
                            if let amount = Decimal(string: amountString) {
                                receiptData.extractedAmount = amount
                                break
                            }
                        }
                    }
                }
            }
            
            // Extraer fecha usando DateFormatter
            let datePatterns = [
                "MM/dd/yyyy",
                "dd/MM/yyyy",
                "yyyy-MM-dd",
                "MMM dd, yyyy",
                "dd MMM yyyy"
            ]
            
            for pattern in datePatterns {
                let formatter = DateFormatter()
                formatter.dateFormat = pattern
                
                if let date = formatter.date(from: text) {
                    receiptData.extractedDate = date
                    break
                }
            }
            
            // Si no se encontró fecha, usar fecha actual
            if receiptData.extractedDate == nil {
                receiptData.extractedDate = Date()
            }
            
            // Extraer comercio (primera línea que no sea fecha o monto)
            let lines = text.components(separatedBy: .newlines)
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedLine.isEmpty && 
                   !trimmedLine.contains("$") && 
                   !trimmedLine.contains("Total") &&
                   !trimmedLine.contains("Amount") &&
                   !trimmedLine.contains("Date") {
                    receiptData.extractedMerchant = trimmedLine
                    break
                }
            }
            
            return receiptData
        }
    }
}
#endif

// MARK: - Receipt Data Model
struct ReceiptData {
    var extractedAmount: Decimal?
    var extractedDate: Date?
    var extractedMerchant: String?
    var rawText: String = ""
    #if os(iOS)
    var originalImage: UIImage?
    #endif
    
    init() {}
}

// MARK: - Receipt Scanner Sheet
struct ReceiptScannerSheet: View {
    @Binding var isPresented: Bool
    @State private var currentStep: ScannerStep = .instructions
    @State private var scannedReceipt: ReceiptData?
    
    let onReceiptScanned: (ReceiptData) -> Void
    
    enum ScannerStep {
        case instructions
        case scanning
        case confirmation
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch currentStep {
                case .instructions:
                    instructionsView
                case .scanning:
                    scanningView
                case .confirmation:
                    if let receipt = scannedReceipt {
                        confirmationView(receipt: receipt)
                    }
                }
            }
            .navigationTitle("Escanear Factura")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
            })
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("Escanear Factura")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Toma una foto de tu factura para extraer automáticamente el monto, fecha y comercio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 32)
            
            Spacer()
            
            // Scanner Button
            Button(action: { 
                currentStep = .scanning
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Escanear Factura")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            
            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("Instrucciones:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text("Asegúrate de que la factura esté bien iluminada")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text("El texto debe ser claro y legible")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text("El monto y fecha se extraerán automáticamente")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var scanningView: some View {
        VStack {
            #if os(iOS)
            ReceiptScannerView(isPresented: .constant(true)) { receiptData in
                scannedReceipt = receiptData
                currentStep = .confirmation
            }
            #else
            Text("Scanner no disponible en macOS")
                .padding()
            #endif
        }
    }
    
    private func confirmationView(receipt: ReceiptData) -> some View {
        ReceiptConfirmationView(
            isPresented: .constant(true),
            receiptData: receipt,
            onSave: { confirmedReceipt in
                onReceiptScanned(confirmedReceipt)
                isPresented = false
            }
        )
    }
}

// MARK: - Receipt Confirmation View
struct ReceiptConfirmationView: View {
    @Binding var isPresented: Bool
    let receiptData: ReceiptData
    let onSave: (ReceiptData) -> Void
    
    @State private var amount: String = ""
    @State private var merchant: String = ""
    @State private var selectedDate = Date()
    @State private var isProcessing = false
    
    private var isValidAmount: Bool {
        guard !amount.isEmpty else { return false }
        // Permitir números con punto decimal
        let cleanAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        return Decimal(string: cleanAmount) != nil && Decimal(string: cleanAmount)! > 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancelar") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Text("Confirmar Factura")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Guardar") {
                    confirmReceipt()
                }
                .disabled(!isValidAmount || isProcessing)
                .foregroundColor(!isValidAmount || isProcessing ? .gray : .blue)
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Preview Image
                    #if os(iOS)
                    if let image = receiptData.originalImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 4)
                    }
                    #endif
                    
                    // Form
                    VStack(spacing: 20) {
                        // Amount Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monto")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .onChange(of: amount) {
                                    // Validar en tiempo real
                                    print("🔍 Amount changed to: '\(amount)'")
                                }
                        }
                        
                        // Merchant Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comercio")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Nombre del comercio", text: $merchant)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Date Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            
            // Processing indicator
            if isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Procesando factura...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .onAppear {
            print("🔍 ReceiptConfirmationView appeared")
            setupInitialValues()
        }
    }
    
    private func setupInitialValues() {
        if let extractedAmount = receiptData.extractedAmount {
            // Mostrar el monto sin formato de moneda para facilitar la edición
            amount = "\(extractedAmount)"
        }
        
        if let extractedMerchant = receiptData.extractedMerchant {
            merchant = extractedMerchant
        }
        
        if let extractedDate = receiptData.extractedDate {
            selectedDate = extractedDate
        }
    }
    
    private func confirmReceipt() {
        print("🔍 confirmReceipt() called")
        guard isValidAmount else {
            print("❌ Invalid amount: \(amount)")
            return 
        }
        
        guard let amountDecimal = Decimal(string: amount.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            print("❌ Could not convert amount to Decimal: \(amount)")
            return
        }
        
        print("✅ Amount valid: \(amountDecimal)")
        
        isProcessing = true
        
        var confirmedReceipt = receiptData
        confirmedReceipt.extractedAmount = amountDecimal
        confirmedReceipt.extractedMerchant = merchant.isEmpty ? "Comercio Desconocido" : merchant
        confirmedReceipt.extractedDate = selectedDate
        
        // Procesar inmediatamente sin delays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("🔍 Calling onSave with receipt")
            self.onSave(confirmedReceipt)
        }
    }
}
