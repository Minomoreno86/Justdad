import SwiftUI

struct AnimatedTextView: View {
    let text: String
    let font: Font
    let color: Color
    let animationDelay: Double
    let animationDuration: Double
    
    @State private var visibleCharacters: Int = 0
    @State private var animationComplete = false
    
    init(
        text: String,
        font: Font = .title,
        color: Color = .white,
        animationDelay: Double = 0.0,
        animationDuration: Double = 2.0
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.animationDelay = animationDelay
        self.animationDuration = animationDuration
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(font)
                    .foregroundColor(color)
                    .opacity(index < visibleCharacters ? 1 : 0)
                    .offset(y: index < visibleCharacters ? 0 : 20)
                    .animation(
                        .easeOut(duration: 0.3)
                        .delay(animationDelay + Double(index) * 0.05),
                        value: visibleCharacters
                    )
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
            withAnimation(.easeOut(duration: animationDuration)) {
                visibleCharacters = text.count
            }
        }
    }
}

struct GlowingTextView: View {
    let text: String
    let font: Font
    let color: Color
    let glowColor: Color
    let glowRadius: CGFloat
    
    @State private var glowIntensity: CGFloat = 0
    
    init(
        text: String,
        font: Font = .title,
        color: Color = .white,
        glowColor: Color = .cyan,
        glowRadius: CGFloat = 10
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.glowColor = glowColor
        self.glowRadius = glowRadius
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .shadow(color: glowColor, radius: glowRadius * glowIntensity)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    glowIntensity = 1
                }
            }
    }
}

struct FloatingTextView: View {
    let text: String
    let font: Font
    let color: Color
    
    @State private var offset: CGFloat = 0
    @State private var rotation: Double = 0
    
    init(
        text: String,
        font: Font = .headline,
        color: Color = .white
    ) {
        self.text = text
        self.font = font
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .offset(y: offset)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                startFloating()
            }
    }
    
    private func startFloating() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            offset = -10
        }
        
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            rotation = 2
        }
    }
}

struct TypewriterTextView: View {
    let fullText: String
    let font: Font
    let color: Color
    let typingSpeed: Double
    
    @State private var displayText = ""
    @State private var currentIndex = 0
    
    init(
        fullText: String,
        font: Font = .body,
        color: Color = .white,
        typingSpeed: Double = 0.05
    ) {
        self.fullText = fullText
        self.font = font
        self.color = color
        self.typingSpeed = typingSpeed
    }
    
    var body: some View {
        HStack {
            Text(displayText)
                .font(font)
                .foregroundColor(color)
            
            if currentIndex < fullText.count {
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: 20)
                    .opacity(0.8)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: currentIndex)
            }
        }
        .onAppear {
            startTyping()
        }
    }
    
    private func startTyping() {
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayText += String(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        AnimatedTextView(
            text: "Terapia del Perdón",
            font: .largeTitle,
            color: .white,
            animationDelay: 0.0
        )
        
        GlowingTextView(
            text: "Liberación Energética",
            font: .title,
            color: .white,
            glowColor: .cyan
        )
        
        FloatingTextView(
            text: "Sanación Pránica",
            font: .headline,
            color: .white
        )
        
        TypewriterTextView(
            fullText: "Iniciando ritual de liberación...",
            font: .body,
            color: .white
        )
    }
    .padding()
    .background(Color.black)
}
