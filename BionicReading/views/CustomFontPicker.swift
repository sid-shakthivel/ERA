//
//  CustomFontPicker.swift
//  BionicReading
//
//  Created by Siddharth Shakthivel Muthu Pandian on 09/10/2022.
//

import SwiftUI
import Foundation

struct CustomFontPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIFontPickerViewController
    @EnvironmentObject var settings: UserCustomisations
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let configuration = UIFontPickerViewController.Configuration()
        configuration.includeFaces = true
        configuration.displayUsingSystemFont = true
        let vc = UIFontPickerViewController(configuration: configuration)
        vc.delegate = context.coordinator
        return vc
    }
    
    func makeCoordinator() -> CustomFontPicker.CustomFontPickerCoordinator {
        return CustomFontPickerCoordinator(self)
    }
    
    public class CustomFontPickerCoordinator: NSObject, UIFontPickerViewControllerDelegate {
        var parent: CustomFontPicker
        
        init (_ parent: CustomFontPicker) {
            self.parent = parent
        }
        
        public func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            print("idk what to do...")
        }
        
        public func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            guard let descriptor = viewController.selectedFontDescriptor else { return }
            
//            let boldDescriptor = descriptor.addingAttributes([.traits: [
//                UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]
//            ])
            
            parent.settings.font = UIFont(descriptor: descriptor, size: CGFloat(parent.settings.fontSize))
            parent.settings.headingFont = UIFont(descriptor: descriptor, size: CGFloat(Double(parent.settings.fontSize) * 1.5))
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
