import Foundation
import UIKit

public class HapticFeedbackManager: ObservableObject {
    public static let shared = HapticFeedbackManager()
    
    @Published var isEnabled = true
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    public func light() {
        impact(.light)
    }
    
    public func medium() {
        impact(.medium)
    }
    
    public func heavy() {
        impact(.heavy)
    }
    
    // MARK: - Selection Feedback
    
    public func selection() {
        guard isEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Notification Feedback
    
    public func success() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    public func warning() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    public func error() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Custom Patterns
    
    public func breathingPattern() {
        guard isEnabled else { return }
        
        // Simulate breathing pattern with haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.light()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.medium()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.light()
        }
    }
    
    public func cordCutting() {
        guard isEnabled else { return }
        
        // Simulate cutting motion with haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.heavy()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.medium()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.light()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.success()
        }
    }
    
    public func liberation() {
        guard isEnabled else { return }
        
        // Celebration pattern for liberation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.medium()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.success()
        }
    }
    
    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
}
