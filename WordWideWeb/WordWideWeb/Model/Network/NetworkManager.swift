//
//  NetworkManager.swift
//  WorldWordWeb
//
//  Created by 신지연 on 2024/05/14.
//

import Foundation

final class NetworkManager: NSObject, ObservableObject {
    
    static let shared = NetworkManager()
    
    var currentElement: String = ""
    var currentItem: Item?
    var currentSenseElement: SenseElement?
    var items: [Item] = []
    
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    
    func fetchAPI(query: String, completion: @escaping ([Item]) -> Void) {
        
        guard let apiKey = apiKey else {
            print("API key not found")
            return
        }
        
        var components = URLComponents(string: "https://krdict.korean.go.kr/api/search")!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "translated", value: "y"),
            URLQueryItem(name: "trans_lang", value: "1"),
        ]
        
        guard let url = components.url else {
            print("Failed to create URL")
            return
        }
        print(url)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            // 응답 코드가 성공(200)인지 확인
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response code: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            self.setXMLParser(data: data)
            
            DispatchQueue.main.async {
                completion(self.items)
            }
        }.resume()
    }
    
    func fetchAPIExactWord(query: String, completion: @escaping (Item) -> Void) {
        
        guard let apiKey = apiKey else {
            print("API key not found")
            return
        }
        
        var components = URLComponents(string: "https://krdict.korean.go.kr/api/search")!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "translated", value: "y"),
            URLQueryItem(name: "trans_lang", value: "1"),
            URLQueryItem(name: "advanced", value: "y"),
            URLQueryItem(name: "target", value: "1")
        ]
        
        guard let url = components.url else {
            print("Failed to create URL")
            return
        }
        print(url)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            // 응답 코드가 성공(200)인지 확인
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response code: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            self.setXMLParser(data: data)
            
            DispatchQueue.main.async {
                if let item = self.items.first {
                    completion(item)
                }
            }
        }.resume()
    }
    
    func setXMLParser(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            print("Parsing succeeded")
        } else {
            print("Parsing failed")
        }
    }
}


extension NetworkManager: XMLParserDelegate {
    // 파싱이 시작될 때 호출됨
    func parserDidStartDocument(_ parser: XMLParser) {
        items = []
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        // Item 요소의 시작을 만났을 때 currentItem을 초기화
        if elementName == "item" {
            currentItem = Item(word: "", pos: "", sense: [])
        } else if elementName == "sense" {
            currentSenseElement = SenseElement(senseOrder: 0, definition: "", transWord: "", transDfn: "")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        // 현재 요소에 해당하는 값들을 currentItem에 할당
        switch currentElement {
        case "word":
            currentItem?.word += data
        case "pos":
            currentItem?.pos += data
        case "definition":
            currentSenseElement?.definition += data
        case "sense_order":
            currentSenseElement?.senseOrder += Int(data) ?? 0
        case "trans_word":
            currentSenseElement?.transWord += data
        case "trans_dfn":
            currentSenseElement?.transDfn += data
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // Item 요소의 끝을 만나면 currentItem을 사용하여 원하는 작업 수행
        if elementName == "item", let item = currentItem {
            items.append(item)
            currentItem = nil
        } else if elementName == "sense", let senseElement = currentSenseElement {
            currentItem?.sense.append(senseElement)
            currentSenseElement = nil
        }
    }
    
//    // 파싱이 끝날 때 호출됨
//    func parserDidEndDocument(_ parser: XMLParser) {
//        print("Parsing finished")
//    }
    
    // 파싱 중 에러 발생 시 호출됨
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error parsing XML: \(parseError.localizedDescription)")
    }
}
