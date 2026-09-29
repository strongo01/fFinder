import Flutter
import UIKit
import VisionKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  
  // Variabele om het resultaat vast te houden en naar Flutter terug te sturen
  private var scanResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Hier wordt de Flutter Engine nu geïnitialiseerd
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    // 1. Maak het kanaal aan met de binaryMessenger van de engineBridge
    let visualChannel = FlutterMethodChannel(name: "com.ffinder.app/visual_intelligence",
                                             binaryMessenger: engineBridge.binaryMessenger)
    
    visualChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "scanProduct" {
          self?.startVisualScan(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  // Functie om de VisionKit camera te openen bovenop Flutter
  private func startVisualScan(result: @escaping FlutterResult) {
      self.scanResult = result
      
      // 2. Controleer of de camera/scanner wordt ondersteund op de iPhone
      guard DataScannerViewController.isSupported && DataScannerViewController.isAvailable else {
          result(FlutterError(code: "UNAVAILABLE", message: "VisionKit scanner is niet beschikbaar op dit apparaat.", details: nil))
          return
      }
      
      // 3. Configureer de scanner. We zoeken hier specifiek naar tekst.
      // Je kunt ook .barcode() toevoegen aan de recognizedDataTypes.
      let dataScanner = DataScannerViewController(
          recognizedDataTypes: [.text()],
          qualityLevel: .accurate,
          recognizesMultipleItems: false,
          isHighFrameRateTrackingEnabled: true,
          isHighlightingEnabled: true
      )
      
      dataScanner.delegate = self
      
      // Haal de root view controller van je Flutter app op
      guard let rootViewController = window?.rootViewController else {
          result(FlutterError(code: "NO_ROOT", message: "Geen root view controller gevonden.", details: nil))
          return
      }
      
      // Laat de native camera overlay zien
      rootViewController.present(dataScanner, animated: true) {
          try? dataScanner.startScanning()
      }
  }
}

// MARK: - DataScannerViewControllerDelegate
extension AppDelegate: DataScannerViewControllerDelegate {
    
    // Wordt aangeroepen wanneer de gebruiker op een herkend stuk tekst/etiket tikt
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        dataScanner.stopScanning()
        dataScanner.dismiss(animated: true)
        
        switch item {
        case .text(let textItem):
            let scannedText = textItem.transcript
            
            // 4. Bouw de JSON om terug te sturen naar je Flutter app.
            // (In iOS 27 zou je hier eventueel de on-device Foundation Models API 
            // kunnen aanroepen om de ruwe tekst semantisch te vertalen naar macro's).
            let productData: [String: Any] = [
                "product_name": scannedText,
                "calories": 150, // Pas dit aan naar een echte dynamische waarde of LLM output
                "is_ai_scanned": true
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: productData, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                // Stuur de JSON string terug naar de HomeScreen in Flutter
                self.scanResult?(jsonString)
            } else {
                self.scanResult?(FlutterError(code: "JSON_ERROR", message: "Kon geen JSON maken.", details: nil))
            }
            
        case .barcode(let barcodeItem):
             self.scanResult?(barcodeItem.payloadStringValue)
             
        @unknown default:
             self.scanResult?(FlutterError(code: "UNKNOWN", message: "Onbekend object gescand.", details: nil))
        }
        
        // Ruim de variabele op
        self.scanResult = nil
    }
    
    // Wordt aangeroepen als de gebruiker de scan annuleert (bijv. omlaag swipen)
    func dataScannerDidCancel(_ dataScanner: DataScannerViewController) {
        dataScanner.stopScanning()
        dataScanner.dismiss(animated: true)
        self.scanResult?(FlutterError(code: "CANCELED", message: "Scan geannuleerd door gebruiker.", details: nil))
        self.scanResult = nil
    }
}