cask "ricochet-app" do
  version "0.2.0"
  sha256 "ca44ab8c56c089c0949c74f8ae96dfdd492541a41245031cf81a2ecfbf3b6f9e"

  url "https://github.com/ricochet-rs/app/releases/download/v#{version}/ricochet-#{version}.dmg",
      verified: "github.com/ricochet-rs/app/"
  name "ricochet"
  desc "Install and run the ricochet data science deployment platform"
  homepage "https://ricochet.rs/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "ricochet.app"

  uninstall launchctl: "rs.ricochet.server",
            quit:      "rs.ricochet.mac"

  zap trash: [
    "~/.local/bin/ricochet-server",
    "~/.local/share/ricochet",
    "~/Library/Application Support/Ricochet",
  ]
end
