import UIKit

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    
    public var hex: UInt {
        let red = UInt(coreImageColor.red * 255 + 0.5)
        let green = UInt(coreImageColor.green * 255 + 0.5)
        let blue = UInt(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }
    
    public var rgba: String {
        let red = Int((coreImageColor.red * 255.0).rounded())
        let green = Int((coreImageColor.green * 255.0).rounded())
        let blue = Int((coreImageColor.blue * 255.0).rounded())
        let alpha = coreImageColor.alpha
        
        if alpha < 1.0 {
            return String(format: "rgba(%d, %d, %d, %.2f)", red, green, blue, alpha)
        } else {
            return String(format: "rgb(%d, %d, %d)", red, green, blue)
        }
    }
    
    public convenience init(hex: UInt) {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }
    
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
        var cleanString = rgb.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // --- DÉBUT DE LA LOGIQUE POUR LE FORMAT HEXADÉCIMAL ---
        
        // 2. Vérifier si le format est hexadécimal (commence par #)
        if cleanString.hasPrefix("#") {
            // On supprime le préfixe '#'
            cleanString.removeFirst()
            
            // Si le format est court (ex: #f0c), on le convertit en format long (ex: #ff00cc)
            if cleanString.count == 3 {
                cleanString = cleanString.map { "\($0)\($0)" }.joined()
            }
            
            // Après conversion, la chaîne doit avoir exactement 6 caractères
            guard cleanString.count == 6 else {
                return nil
            }
            
            // On convertit la chaîne hexadécimale en une valeur numérique (UInt)
            var hexValue: UInt64 = 0
            let scanner = Scanner(string: cleanString)
            
            // Si la conversion échoue, ce n'est pas une couleur valide
            guard scanner.scanHexInt64(&hexValue) else {
                return nil
            }
            
            // On extrait les composantes rouge, verte et bleue de la valeur numérique
            let r = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(hexValue & 0x0000FF) / 255.0
            
            // On initialise la couleur et on sort de la fonction
            self.init(red: r, green: g, blue: b, alpha: 1.0)
            return
        }
        
        // --- FIN DE LA LOGIQUE HEXADÉCIMALE ---
        // Si ce n'est pas un format hex, on continue avec la logique existante pour rgb() et rgba()
        
        let isRgba = cleanString.hasPrefix("rgba(")
        let isRgb = cleanString.hasPrefix("rgb(")
        
        guard (isRgb || isRgba) && cleanString.hasSuffix(")") else {
            return nil
        }
        
        let startIndex = cleanString.index(cleanString.startIndex, offsetBy: isRgba ? 5 : 4)
        let endIndex = cleanString.index(before: cleanString.endIndex)
        let componentsString = String(cleanString[startIndex..<endIndex])
        
        let components = componentsString
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        
        if isRgba {
            guard components.count == 4 else { return nil }
            let r = components[0]
            let g = components[1]
            let b = components[2]
            let a = components[3]
            
            guard (0...255).contains(r) && (0...255).contains(g) && (0...255).contains(b) && (0.0...1.0).contains(a) else {
                return nil
            }
            
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
            
        } else { // isRgb
            guard components.count == 3 else { return nil }
            let r = components[0]
            let g = components[1]
            let b = components[2]
            
            guard (0...255).contains(r) && (0...255).contains(g) && (0...255).contains(b) else {
                return nil
            }
            
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
        }
    }
}
