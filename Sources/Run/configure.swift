import Vapor

func configure(_ s: inout Services) {
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }
}
