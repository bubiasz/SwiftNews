//
//  ScannerView.swift
//  SwiftNews
//

import AVKit
import SwiftData
import SwiftUI

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var url: String?
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else {
                return
            }
            guard let code = readableObject.stringValue else {
                return
            }
            if String(code.prefix(34)) == "http://172.20.10.3:8080/api/qrcode" {
                url = code
            }
        }
    }
}

struct CameraView: UIViewRepresentable {
    @Binding var session: AVCaptureSession
    var size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let camera = AVCaptureVideoPreviewLayer(session: session)
        camera.frame = .init(origin: .zero, size: size)
        camera.videoGravity = .resizeAspectFill
        camera.masksToBounds = true
        
        let view = UIViewType(frame: CGRect(origin: .zero, size: size))
        view.backgroundColor = .clear
        view.layer.addSublayer(camera)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}


struct ScannerView: View {
    // Environment variables
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // Database queries
    @Query private var userQuery: [UserModel]
    
    // Code scanner variables
    @State private var url: String = ""
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    @StateObject private var qrDelegate = QRScannerDelegate()
    
    // Alert variables
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showError: Bool = false
    @State private var activeAlert: ActiveAlert = .error
    @State private var error: Bool = false
    
    private enum Permission: String {
        case idle = "Not Determined"
        case approved = "Access Granted"
        case denied = "Access Denied"
    }
    
    private enum ActiveAlert: String {
        case error, config, done
    }
    
    private enum ViewError: Error {
        case fetchFailed, saveFailed
    }
    
    // View implementation
    var body: some View {
        VStack {
            ZStack {
                CameraView(session: $session, size: CGSize(width: 200, height: 200))
                    .scaleEffect(0.98)
                
                ForEach(0...4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2, style: .circular)
                        .trim(from: 0.60, to: 0.65)
                        .stroke(Color.foreground, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.init(degrees: Double(index) * 90))
                }
            }
            .frame(width: 200, height: 200)
            .overlay(alignment: .top, content: {
                Rectangle()
                    .fill(Color.foreground)
                    .frame(height: 2)
                    .offset(y: isScanning ? 200 : 0)
            })
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            
            Text("Scanning will start automatically if not click the button below")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray)
                .font(.caption)
                .padding()
            
            Button {
                if !session.isRunning && cameraPermission == .approved {
                    reactivateCamera()
                    activateScannerAnimation()
                }
            } label: {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Start scanning")
                }
                .padding()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .background(Color.foreground)
                .foregroundStyle(Color.background)
                .cornerRadius(8)
            }
        }
        .padding(50)
        .navigationBarTitle("Scanner", displayMode: .inline)
        .onAppear(perform: checkCameraPermission)
        .onDisappear {
            session.stopRunning()
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .error:
                return Alert(title: Text(errorMessage), primaryButton: .default(Text("Settings")) {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        openURL(settingsURL)
                    }
                }, secondaryButton: .cancel())
            case .config:
                return Alert(title: Text("Import config"), message: Text("Would you like to import config? It can't be undone!"), primaryButton: .default(Text("Continue")) {
                    
                    try? updateUserInfo()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        activeAlert = .done
                        showAlert.toggle()
                    }
                    
                }, secondaryButton: .cancel() {
                    reactivateCamera()
                    activateScannerAnimation()
                })
            case .done:
                return Alert(title: Text(error ? "Encountered a problem" : "Operation successful"), message: Text(error ? " Problem with handling response from API" : "Settings were imported into your app"), dismissButton: .default(Text("Continue")))
            }
        }
        .onChange(of: showError) { oldValue, newValue in
            if newValue {
                activeAlert = .error
                showAlert = true
            }
        }
        .onChange(of: qrDelegate.url) { oldValue, newValue in
            if let code = newValue {
                url = code
                
                session.stopRunning()
                deactivateScannerAnimation()
                
                qrDelegate.url = nil
                
                activeAlert = .config
                showAlert = true
            }
        }
    }
    
    func updateUserInfo() throws {
        Task {
            var codeSchema: CodeSchema
            do {
                codeSchema = try await APIManager.shared.getData(from: "qrcode/\(String(url.suffix(65)))")
            }
            catch {
                self.error = true
                throw ViewError.fetchFailed
            }
            
            var categories: [String: Int] = [:]
            for (category, value) in codeSchema.categories {
                categories[category] = value
            }
            
            let userModel: UserModel = UserModel(
                id: codeSchema.user,
                time: codeSchema.time,
                location: codeSchema.location,
                categories: categories
            )
            
            do {
                try modelContext.delete(model: UserModel.self)
                modelContext.insert(userModel)
                try modelContext.save()
            }
            catch {
                self.error = true
                throw ViewError.saveFailed
            }
        }
    }
    
    func reactivateCamera() {
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    func activateScannerAnimation() {
        withAnimation(.easeInOut(duration: 1).delay(0.25).repeatForever(autoreverses: true)) {
            isScanning = true
        }
    }
    
    func deactivateScannerAnimation() {
        withAnimation(.easeInOut(duration: 1)) {
            isScanning = false
        }
    }
    
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                
                if session.inputs.isEmpty {
                    setupCamera()
                }
                else {
                    reactivateCamera()
                }
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    setupCamera()
                }
                else {
                    cameraPermission = .denied
                    presentError("Please provide access to the camera in order to scan SQ code")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please provide access to the camera in order to scan SQ code")
            default: break
            }
        }
    }
    
    func setupCamera() {
        do {
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera], mediaType: .video, position: .back).devices.first else {
                presentError("Unknown device error")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("Unknown input/output error")
                return
            }
            
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            
            qrOutput.metadataObjectTypes = [.qr]
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            activateScannerAnimation()
        }
        catch {
            presentError(error.localizedDescription)
        }
    }
    
    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
    }
}
