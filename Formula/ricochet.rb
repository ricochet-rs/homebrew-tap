class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "b01cc142f9ec7f7e60f3381b401aa2672248f2c9c9bb9ee73263ca2ce9f7e35c"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  bottle do
    root_url "https://github.com/ricochet-rs/homebrew-tap/releases/download/v0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "5e7cbbc5315e55d51c2d8a215b9079c2005f6294a3a5666a630987995770dbd9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f793f0170e42434c513c3a8a0d8d1d4d43f602c16a00d5ace4798f981d22a948"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "78828d036acaf7a95a2dd0bd4485c1f0d299a5316c0db5aefd9a496af53e2c04"
    sha256 cellar: :any_skip_relocation, sequoia:       "41daf4aca1df864c54b3a9a432be067604c87d35bcc57d45635ec52fdc562911"
  end

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        tag: "v0.3.0",
        revision: "261dce7ec307133c8b6d5894cc104e2e5870d5cd",
        using: :git
  end

  depends_on "rust" => :build

  # Pass through environment for git auth (private dependencies)
  env :std

  def install
    # Stage the private dependency locally
    (buildpath/"deps/ricochet").install resource("ricochet-core")

    # Patch the git dependency to use local path
    File.open(buildpath/".cargo/config.toml", "a") do |f|
      f.puts <<~TOML

        [patch."https://github.com/ricochet-rs/ricochet"]
        ricochet-core = { path = "#{buildpath}/deps/ricochet/ricochet-core" }
      TOML
    end

    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "ricochet", shell_output("#{bin}/ricochet --help")
    system bin/"ricochet", "--version"
  end
end
