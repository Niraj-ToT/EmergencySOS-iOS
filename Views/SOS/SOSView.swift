import SwiftUI

struct SOSView: View {
    @StateObject private var viewModel = SOSViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    switch viewModel.sosState {
                    case .idle:
                        IdleSOSView(onStart: { viewModel.startSOSConfirmation() })
                    
                    case .confirming:
                        ConfirmingSOSView(countdown: viewModel.countdown, onCancel: { viewModel.cancelSOSConfirmation() })
                    
                    case .activating:
                        ActivatingSOSView()
                    
                    case .active(let alert):
                        ActiveSOSView(alert: alert, liveLocations: viewModel.liveLocations, onEnd: { Task { await viewModel.endSOS() } })
                    
                    case .ending:
                        EndingSOSView()
                    
                    case .ended:
                        EndedSOSView(onDismiss: { dismiss() })
                    
                    case .cancelled:
                        CancelledSOSView(onDismiss: { dismiss() })
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Emergency SOS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if case .idle = viewModel.sosState {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct IdleSOSView: View {
    let onStart: () -> Void
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "sos")
                .font(.system(size: 100))
                .foregroundColor(.red)
                .scaleEffect(pulse ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
                .onAppear { pulse = true }
            
            VStack(spacing: 8) {
                Text("Emergency SOS")
                    .font(.largeTitle.bold())
                
                Text("Press and hold the button below to alert your emergency contacts and share your location")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onStart) {
                Text("Activate SOS")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.red)
        }
    }
}

struct ConfirmingSOSView: View {
    let countdown: Int
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(countdown) / 5)
                    .stroke(Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: countdown)
                
                Text("\(countdown)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Activating in \(countdown)...")
                    .font(.title2.bold())
                
                Text("Release to cancel")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
}

struct ActivatingSOSView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2)
                .tint(.red)
            
            Text("Activating Emergency...")
                .font(.title2.bold())
            
            Text("Getting your location and notifying contacts")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct ActiveSOSView: View {
    let alert: SOSAlert
    let liveLocations: [LiveLocation]
    let onEnd: () -> Void
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
                    .onAppear { pulse = true }
                
                Image(systemName: "location.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("EMERGENCY ACTIVE")
                    .font(.title.bold())
                    .foregroundColor(.red)
                
                Text("Your location is being shared with \(liveLocations.isEmpty ? "contacts" : "\(liveLocations.count) updates sent")")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onEnd) {
                Text("End Emergency")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
        }
    }
}

struct EndingSOSView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2)
                .tint(.green)
            
            Text("Ending Emergency...")
                .font(.title2.bold())
            
            Text("Stopping location sharing")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct EndedSOSView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Emergency Ended")
                .font(.largeTitle.bold())
            
            Text("Your emergency contacts have been notified that you're safe")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onDismiss) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct CancelledSOSView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("SOS Cancelled")
                .font(.largeTitle.bold())
            
            Text("No emergency alert was sent")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onDismiss) {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    SOSView()
}