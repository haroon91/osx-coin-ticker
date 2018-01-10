//
//  Currency.swift
//  CoinTicker
//
//  Created by Alec Ananian on 5/31/17.
//  Copyright © 2017 Alec Ananian.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Cocoa

enum Currency: Int, Codable {
    
    // Physical
    case cad, cny, eur, gbp, jpy, krw, rub, usd
    
    // Crypto
    case ada, adx, aion, amp, ardr, ark, bat, bch, bcn, bnb, bnt, bqx, btc, btcd, btg, btm, bts, cvc,
        dash, dcr, dgb, doge, emc2, eos, etc, eth, etp, fct, fun, game, gno, gnt, gxs, hsr, icn, iota,
        kmd, knc, lrc, lsk, ltc, maid, mana, mco, mln, mtl, nav, nebl, neo, nmc, nvc, nxt, omg,
        pot, ppc, ppt, qash, qtum, rdn, rep, ric, salt, san, sc, sngls, snt, steem, storj, strat, sub,
        trx, usdt, ven, vtc, waves, wtc, xcp, xem, xlm, xmr, xrp, xvg, xzc, zec
    
    private static let AllPhysical = [
        cad, cny, eur, gbp, jpy, krw, rub, usd
    ]
    
    private static let AllCrypto = [
        ada, adx, aion, amp, ardr, ark, bat, bch, bcn, bnb, bnt, bqx, btc, btcd, btg, btm, bts, cvc,
        dash, dcr, dgb, doge, emc2, eos, etc, eth, etp, fct, fun, game, gno, gnt, gxs, hsr, icn, iota,
        kmd, knc, lrc, lsk, ltc, maid, mana, mco, mln, mtl, nav, nebl, neo, nmc, nvc, nxt, omg,
        pot, ppc, ppt, qash, qtum, rdn, rep, ric, salt, san, sc, sngls, snt, steem, storj, strat, sub,
        trx, usdt, ven, vtc, waves, wtc, xcp, xem, xlm, xmr, xrp, xvg, xzc, zec
    ]
    
    private static let AllValues = AllCrypto + AllPhysical
    
    var code: String {
        return String(describing: self).uppercased()
    }
    
    var displayName: String {
        return String.LocalizedStringWithFallback("currency.\(code.lowercased()).title", comment: "Currency Title")
    }
    
    var symbol: String? {
        switch self {
        case .rub: return "₽"
        case .btc, .bch: return "₿"
        case .doge: return "Ð"
        case .etc: return "⟠"
        case .eth: return "Ξ"
        case .ltc: return "Ł"
        case .nmc: return "ℕ"
        case .ppc: return "Ᵽ"
        case .rep: return "Ɍ"
        case .xmr: return "ɱ"
        case .xrp: return "Ʀ"
        case .zec: return "ⓩ"
        default: return (isCrypto ? code : nil)
        }
    }
    
    var iconImage: NSImage? {
        return (NSImage(named: NSImage.Name(rawValue: code)) ?? smallIconImage)
    }
    
    var smallIconImage: NSImage? {
        return NSImage(named: NSImage.Name(rawValue: "\(code)_small"))
    }
    
    var isCrypto: Bool {
        return Currency.AllCrypto.contains(self)
    }
    
    var isBitcoin: Bool {
        return (self == .btc)
    }
    
    private var isBitcoinCash: Bool {
        return (self == .bch)
    }
    
    static func build(fromCode code: String?) -> Currency? {
        guard var normalizedCode = code?.uppercased() else {
            return nil
        }
        
        if let currency = AllValues.first(where: { $0.code.uppercased() == normalizedCode }) {
            return currency
        }
        
        // Further normalization for Kraken API which prefixes X for crypto currencies and Z for physical
        if normalizedCode.count >= 4 && (normalizedCode.first == "X" || normalizedCode.first == "Z") {
            normalizedCode = String(normalizedCode.suffix(normalizedCode.count - 1))
            if let currency = AllValues.first(where: { $0.code.uppercased() == normalizedCode }) {
                return currency
            }
        }
        
        // Group certain codes
        switch normalizedCode {
        case "BCC": return .bch
        case "RUR": return .rub
        case "XBT": return .btc
        case "XDG": return .doge
        default: return nil
        }
    }
    
    static func build(fromLocale locale: Locale) -> Currency? {
        guard let currencyCode = locale.currencyCode else {
            return nil
        }
        
        return Currency.build(fromCode: currencyCode)
    }
    
    static func <(lhs: Currency, rhs: Currency) -> Bool {
        if lhs.isBitcoin && !rhs.isBitcoin {
            return true
        }
        
        if !lhs.isBitcoin && rhs.isBitcoin {
            return false
        }
        
        if lhs.isBitcoinCash && !rhs.isBitcoin && !rhs.isBitcoinCash {
            return true
        }
        
        return lhs.code < rhs.code
    }
    
}

