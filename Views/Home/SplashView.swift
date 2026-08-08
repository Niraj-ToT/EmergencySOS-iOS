import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("EmergencySOS")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Your safety companion")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SplashView()
}