import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingSOS = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // SOS Button
                        SOSButton(isActive: viewModel.activeSOSAlert != nil) {
                            showingSOS = true
                        }
                        
                        // Quick Stats
                        if let user = viewModel.user {
                            UserInfoCard(user: user)
                        }
                        
                        // Favorite Contacts
                        if !viewModel.favoriteContacts.isEmpty {
                            FavoriteContactsSection(contacts: viewModel.favoriteContacts)
                        }
                        
                        // Active SOS Alert
                        if let alert = viewModel.activeSOSAlert {
                            ActiveSOSCard(alert: alert) {
                                Task { await viewModel.endSOS() }
                            }
                        }
                        
                        // Map Preview
                        MapPreview(region: $region, alert: viewModel.activeSOSAlert)
                    }
                    .padding()
                }
            }
            .navigationTitle("EmergencySOS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSOS) {
                SOSView()
            }
            .task {
                await viewModel.loadInitialData()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

struct SOSButton: View {
    let isActive: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isActive ? Color.red : Color.red.gradient)
                    .frame(width: 180, height: 180)
                    .shadow(color: .red.opacity(0.5), radius: isPressed ? 10 : 20, x: 0, y: 10)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                VStack(spacing: 8) {
                    Image(systemName: "sos")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(isActive ? "ACTIVE" : "SOS")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text(isActive ? "Tap to end" : "Press & hold")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .buttonStyle(SOSButtonStyle())
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityLabel("Emergency SOS")
        .accessibilityHint(isActive ? "Tap to end emergency" : "Press and hold to activate emergency SOS")
    }
}

struct SOSButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct UserInfoCard: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: user.profileImageURL.flatMap(URL.init)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .overlay(Text(user.name.prefix(1)).font(.title.bold()).foregroundColor(.red))
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text(user.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let bloodGroup = user.bloodGroup {
                    Label(bloodGroup, systemImage: "drop.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct FavoriteContactsSection: View {
    let contacts: [EmergencyContact]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emergency Contacts")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(contacts) { contact in
                        ContactCard(contact: contact)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ContactCard: View {
    let contact: EmergencyContact
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(Text(contact.name.prefix(1)).font(.title2.bold()).foregroundColor(.blue))
            
            Text(contact.name)
                .font(.subheadline.bold())
                .lineLimit(1)
            
            Text(contact.relationship)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if contact.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ActiveSOSCard: View {
    let alert: SOSAlert
    let onEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("EMERGENCY ACTIVE", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline.bold())
                    .foregroundColor(.red)
                Spacer()
                Text(alert.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Location: \(alert.latitude, specifier: "%.4f"), \(alert.longitude, specifier: "%.4f")")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onEnd) {
                Text("End Emergency")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red, lineWidth: 2)
        )
    }
}

struct MapPreview: View {
    @Binding var region: MKCoordinateRegion
    let alert: SOSAlert?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .padding(.horizontal)
            
            Map(coordinateRegion: $region, annotationItems: alert.map { [$0] } ?? []) { alert in
                MapAnnotation(coordinate: alert.coordinate) {
                    Image(systemName: "location.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .background(Circle().fill(.white).frame(width: 30, height: 30))
                }
            }
            .frame(height: 200)
            .cornerRadius(16)
            .disabled(true)
        }
    }
}

#Preview {
    HomeView()
}