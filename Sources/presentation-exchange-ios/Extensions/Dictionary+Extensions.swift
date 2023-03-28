import Foundation

extension Dictionary where Key == String, Value == Any {

    enum JSONParseError: Error {
        case fileNotFound(filename: String)
        case dataInitialisation(Error)
        case jsonSerialization(Error)
        case mappingFail(value: Any, toType: Any)
    }

    static func from(JSONfile url: URL) -> Result<Self, JSONParseError> {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch let error {
            return .failure(.dataInitialisation(error))
        }

        let jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        } catch let error {
            return .failure(.jsonSerialization(error))
        }

        guard let jsonResult = jsonObject as? Self else {
            return .failure(.mappingFail(value: jsonObject, toType: Self.Type.self))
        }

        return .success(jsonResult)
    }

    static func from(localJSONfile name: String) -> Result<Self, JSONParseError> {
        let fileType = "json"
        let fullFileName = name + (name.contains(fileType) ? "" : ".\(fileType)")
        guard let path = Bundle.main.path(forResource: fullFileName, ofType: "") else {
            return .failure(.fileNotFound(filename: fullFileName))
        }
        return from(JSONfile: URL(fileURLWithPath: path))
    }
}
