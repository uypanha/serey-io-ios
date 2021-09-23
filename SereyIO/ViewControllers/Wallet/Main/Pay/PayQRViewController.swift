//
//  PayQRViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/9/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import AVFoundation
import RxCocoa
import RxSwift
import RxBinding

class PayQRViewController: BaseViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var viewMyQRButton: TextBelowImageButton!
    @IBOutlet weak var scanFrameImageView: UIImageView!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var metadataOutput: AVCaptureMetadataOutput!
    
    var viewModel: PayQRViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer?.frame = self.cameraView.layer.bounds
        metadataOutput?.rectOfInterest = self.convertRectOfInterest(rect: self.scanFrameImageView.frame)
        
        self.flashButton.makeMeCircular()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.captureSession?.startRunning()
    }
}

// MARK: - Preparations & Tools
extension PayQRViewController {
    
    func setUpViews() {
        self.flashButton.setImage(self.isTorchOn() ? R.image.flashOffIcon() : R.image.flashOnIcon(), for: .normal)
        self.flashButton.customStyle(with: UIColor(hexString: "BCBCBC"))
        self.flashButton.isHidden = !self.hasTorch()
        
        self.viewMyQRButton.spacing = 8
        self.viewMyQRButton.setTitleColor(ColorName.primary.color, for: .normal)
        self.viewMyQRButton.customStyle(with: nil)
        
        prepareCameraPreview()
    }
    
    func convertRectOfInterest(rect: CGRect) -> CGRect {
        let screenRect = self.cameraView.frame
        let screenWidth = screenRect.width
        let screenHeight = screenRect.height
        let newX = 1 / (screenWidth / rect.minX)
        let newY = 1 / (screenHeight / rect.minY)
        let newWidth = 1 / (screenWidth / rect.width)
        let newHeight = 1 / (screenHeight / rect.height)
        return CGRect(x: newY, y: newX, width: newHeight, height: newWidth)
    }
    
    func validateFlashIcon() {
        self.flashButton.setImage(self.isTorchOn() ? R.image.flashOffIcon() : R.image.flashOnIcon(), for: .normal)
        self.flashButton.customStyle(with: UIColor(hexString: "BCBCBC"))
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension PayQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func prepareCameraPreview() {
        self.cameraView.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch { return }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            metadataOutput.rectOfInterest = self.convertRectOfInterest(rect: self.scanFrameImageView.frame)
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.cameraView.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            guard let username = CryptLib().decryptCipherTextRandomIV(withCipherText: stringValue, key: AES.AES_KEY) else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            captureSession.stopRunning()
            self.viewModel.didAction(with: .qrFound(username))
        }
    }
    
    private func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                device.torchMode = device.torchMode == .on ? .off : .on
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
        
        self.validateFlashIcon()
    }
    
    private func isTorchOn() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        
        if device.hasTorch, let _ = try? device.lockForConfiguration() {
            return device.torchMode == .on
        }
        
        return false
    }
    
    private func hasTorch() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        
        return device.hasTorch
    }
}

// MARK: - SetUp RxObservers
extension PayQRViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.closeButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }) ~ self.disposeBag
        
        self.flashButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.toggleTorch()
            }) ~ self.disposeBag
        
        self.viewMyQRButton.rx.tap.asObservable()
            .map { PayQRViewModel.Action.viewMyQRPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .receiveQRCodeController(let receiveCoinViewModel):
                    if let receiveCoinViewController = R.storyboard.qrPayment.receiveCoinViewController() {
                        receiveCoinViewController.viewModel = receiveCoinViewModel
                        receiveCoinViewController.modalPresentationStyle = .overCurrentContext
                        receiveCoinViewController.modalTransitionStyle = .crossDissolve
                        self?.present(receiveCoinViewController, animated: true, completion: nil)
                    }
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
