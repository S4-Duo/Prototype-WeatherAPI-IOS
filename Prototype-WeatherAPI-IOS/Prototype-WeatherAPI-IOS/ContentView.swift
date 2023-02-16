import SwiftUI

struct ContentView: View {
    let apiKey = "10d75ce922ba55bf2abd1dae42d58e54"
    let city = "Maasbree"
    let units = "metric"
    
    @State var temperature: Double?
    @State var description: String?
    @State var error: String?
    
    var body: some View {
        VStack {
            if let temperature = temperature, let description = description {
                Text("\(city): \(temperature)°C - \(description)")
            } else if let error = error {
                Text("Error: \(error)")
            } else {
                Text("Loading...")
            }
        }
        .onAppear(perform: fetchData)
    }
    
    func fetchData() {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=\(units)&appid=\(apiKey)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                // Check for errors
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                // Check for a successful response
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    self.error = "Invalid response"
                    return
                }
                
                // Check that we received data
                guard let data = data else {
                    self.error = "No data received"
                    return
                }
                
                // Parse the JSON response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Update the UI with the data
                        if let main = json["main"] as? [String: Any],
                           let temp = main["temp"] as? Double {
                            self.temperature = temp
                        }
                        
                        if let weatherArray = json["weather"] as? [[String: Any]],
                           let weather = weatherArray.first,
                           let description = weather["description"] as? String {
                            self.description = description
                        }
                    }
                } catch {
                    self.error = error.localizedDescription
                }
            }
            task.resume()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
