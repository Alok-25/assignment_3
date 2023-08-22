//
//  ViewController.swift
//  TheNumberGame
//
//  Created by Inito on 22/08/23.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var textLabel: UILabel!
    
    
    private var peripheralManager : CBPeripheralManager!
    private var myService: CBMutableService!
    private let value = "AD34E"
    let kServiceUUID = "A56E51F3-AFFE-4E14-87A2-54927B22354C"
    let kGeneratedRandomNumberCharUUID = "0001"
    let kReadingRandomNumberCharUUID = "0002"
    let kDownloadStatusCharUUID = "0003"
    let kNumberOfRoundsCharUUID = "0004"
    var generatedRandomNumberChar: CBMutableCharacteristic!
    var readingRandomNumberChar: CBMutableCharacteristic!
    var numberOfRounds = 0
    let imageURLArray = ["https://dqxth8lmt6m4r.cloudfront.net/assets/v1/reflective_monitor-5d3640f9e6550d48f3d12fb58af880b38a9d1345b35e7d2a1718386850af70d5.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/reflective_monitor-5d3640f9e6550d48f3d12fb58af880b38a9d1345b35e7d2a1718386850af70d5.png","https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_10_no_discount-c5ebe5488dffb7c5bf468093116f2c0224c4de191c364c029f8367cbdffd5538.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_10_no_discount-c5ebe5488dffb7c5bf468093116f2c0224c4de191c364c029f8367cbdffd5538.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_15_with_discount-20c3b131f10b2eac07c5bb16467a5da692d076869e46c83e8c1d01069218c689.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_25_with_discount-d66f0b9ad958a6135e8afb77c1a4f6e1123344180f324f346e713f383538ecc5.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_10_no_discount-c5ebe5488dffb7c5bf468093116f2c0224c4de191c364c029f8367cbdffd5538.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_15_with_discount-20c3b131f10b2eac07c5bb16467a5da692d076869e46c83e8c1d01069218c689.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_25_with_discount-d66f0b9ad958a6135e8afb77c1a4f6e1123344180f324f346e713f383538ecc5.png"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = "Starting Bluetooth"
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
            addServices()
        @unknown default:
            print("Unknown State")
        }
    }
    
    func addServices(){
        
        let valueData = value.data(using: .utf8)
        //Creating characterstics for services
        
        generatedRandomNumberChar = CBMutableCharacteristic(
            type: CBUUID(string: kGeneratedRandomNumberCharUUID),
            properties: [.read, .write,.notify],
            value: nil,
            permissions: [.readable]
        )
        
        readingRandomNumberChar = CBMutableCharacteristic(
            type: CBUUID(string: kReadingRandomNumberCharUUID),
            properties: [.write, .read, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        let downloadStatusChar = CBMutableCharacteristic(
            type: CBUUID(string: kDownloadStatusCharUUID),
            properties: [.notify, .read],
            value: nil,
            permissions: [.readable]
        )
        
        let numberOfRoundsChar = CBMutableCharacteristic(
            type: CBUUID(string: kNumberOfRoundsCharUUID),
            properties: [.read],
            value: nil,
            permissions: [.readable]
        )
        
        //Creating services
        let serviceUUID = CBUUID(string: kServiceUUID)
        myService = CBMutableService(type: serviceUUID, primary: true)
        myService.characteristics = [generatedRandomNumberChar, readingRandomNumberChar, downloadStatusChar,numberOfRoundsChar]
        
        peripheralManager.add(myService!)
        
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey : "electronic", CBAdvertisementDataServiceUUIDsKey : [self.myService!.uuid]])
        
        var randomValue = randomNumberGenerator()
        let data = Data(bytes: &randomValue, count: MemoryLayout.size(ofValue: randomValue))
        generatedRandomNumberChar.value = data
        
        
        
        
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Start advertising failed: \(error.localizedDescription)")
            return
        }
        print("Start advertising succeeded")
        textLabel.text = "Started advertising"
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        
        // Check if the request is for the generatedRandomNumberChar characteristic
        print ("Recieved read request")
        
        
        if request.characteristic == generatedRandomNumberChar {
            numberOfRounds += 1
            if numberOfRounds > 8{
                var randomValue = 0
                let data = Data(bytes: &randomValue, count: MemoryLayout.size(ofValue: randomValue))
                generatedRandomNumberChar.value = data
                
                // Respond to the read request with the updated value
                request.value = data
                peripheral.respond(to: request, withResult: .success)
                return
            }
            
            
            
            // Respond to the read request with the updated value
            request.value = generatedRandomNumberChar.value
            peripheral.respond(to: request, withResult: .success)
        }
        //startTimerToUpdateCharacteristic()
        
        
    }
    
    func updateRandomNumberCharacteristic() {
        var randomValue = randomNumberGenerator()
        let data = Data(bytes: &randomValue, count: MemoryLayout.size(ofValue: randomValue))
        generatedRandomNumberChar.value = data
        
        // Notify the central device with the updated value
        print("Sent Random number: \(randomValue)")
        peripheralManager.updateValue(data, for: generatedRandomNumberChar, onSubscribedCentrals: nil)
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            numberOfRounds += 1
            if request.characteristic == readingRandomNumberChar {
               
                if let data = request.value {
                    let writtenValue = UInt8(bigEndian: data.withUnsafeBytes { $0.load(as: UInt8.self) })
                    
                    performFunctionWithWrittenValue(writtenValue)
                }
                
                // Respond to the write request
                peripheral.respond(to: request, withResult: .success)
            }
        }
    }
    
    func performFunctionWithWrittenValue(_ value: UInt8) {
        if numberOfRounds > 7{
            let imageDownloader = ImageDownloader()
            print("Recived random number : \(value)")
            imageDownloader.downloadAllImages(Int(value)) {
                result in
                print("Game Over")
            }
                
        var randomValue: UInt32 = 0
        let data = Data(bytes: &randomValue, count: MemoryLayout.size(ofValue: randomValue))
        self.generatedRandomNumberChar.value = data
        self.peripheralManager.updateValue(data, for: self.generatedRandomNumberChar, onSubscribedCentrals: nil)
            return
        }
        let imageDownloader = ImageDownloader()
        print("Recived random number : \(value)")
        imageDownloader.downloadAllImages(Int(value)) { result in
            switch result {
                case .success:
                    // Image download succeeded
                self.updateRandomNumberCharacteristic()
                
                case .failure(let error):
                    // Image download failed
                    print("Image download error: \(error)")
                    var randomValue: UInt32 = 0
                    let data = Data(bytes: &randomValue, count: MemoryLayout.size(ofValue: randomValue))
                self.generatedRandomNumberChar.value = data
                self.peripheralManager.updateValue(data, for: self.generatedRandomNumberChar, onSubscribedCentrals: nil)
            }
        }
       
        
    }
    
    
       
   


    func randomNumberGenerator() -> UInt8{
       return UInt8.random(in: 1..<5)
    }

}


