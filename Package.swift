import PackageDescription

let package = Package(
    name: "Monzo",
    dependencies: [
        .Package(url: "https://github.com/marius-serban/S4.git", "0.12.2"),
        .Package(url: "https://github.com/IBM-Swift/CCurl", "0.2.3") // temporary, for URL form encoding
    ]
)
