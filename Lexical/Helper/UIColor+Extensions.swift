import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    public convenience init?(rgb: String) {
        // 1. Nettoyer la chaîne pour la rendre plus facile à analyser
        let cleanString = rgb.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let isRgba = cleanString.hasPrefix("rgba(")
        let isRgb = cleanString.hasPrefix("rgb(")
        
        // 2. Vérifier que le format est correct (commence par rgb/rgba et finit par ')')
        guard (isRgb || isRgba) && cleanString.hasSuffix(")") else {
            return nil
        }
        
        // 3. Extraire les nombres entre les parenthèses
        let startIndex = cleanString.index(cleanString.startIndex, offsetBy: isRgba ? 5 : 4)
        let endIndex = cleanString.index(before: cleanString.endIndex)
        let componentsString = String(cleanString[startIndex..<endIndex])
        
        // 4. Séparer les composantes et les convertir en nombres (Double)
        let components = componentsString
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        
        // 5. Valider et créer la couleur
        if isRgba {
            // Pour rgba, nous attendons 4 composantes (r, g, b, a)
            guard components.count == 4 else { return nil }
            let r = components[0]
            let g = components[1]
            let b = components[2]
            let a = components[3]
            
            // Valider que les valeurs sont dans les bonnes plages (0-255 pour rgb, 0-1 pour alpha)
            guard (0...255).contains(r) && (0...255).contains(g) && (0...255).contains(b) && (0.0...1.0).contains(a) else {
                return nil
            }
            
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
            
        } else { // isRgb
            // Pour rgb, nous attendons 3 composantes (r, g, b)
            guard components.count == 3 else { return nil }
            let r = components[0]
            let g = components[1]
            let b = components[2]
            
            // Valider que les valeurs sont dans la bonne plage (0-255)
            guard (0...255).contains(r) && (0...255).contains(g) && (0...255).contains(b) else {
                return nil
            }
            
            // L'alpha est de 1.0 par défaut pour le format rgb
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
        }
    }
}
