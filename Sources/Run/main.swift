import Vapor

let app = try Application(environment: .detect(), configure: {
    var s = Services.default()
    configure(&s)
    return s
})
defer { app.shutdown() }
try app.run()
