import PackageDescription

let package = Package(
    name: "Monzo",
    dependencies: [
        .Package(url: "https://github.com/marius-serban/S4.git", "0.12.2"),
        .Package(url: "https://github.com/marius-serban/CcURL", "1.1.1") // temporary, for URL form encoding according to RFC 3986
    ]
)
