class Ricochet < Formula
  desc "Put R & Julia in production"
  homepage "https://github.com/ricochet-rs/cli"
  url "https://github.com/ricochet-rs/cli/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "864b4487833ee92c59168bde7112137b439fffa975d4eefc9be23bbb07190472"
  license "AGPL-3.0-or-later"
  head "https://github.com/ricochet-rs/cli.git", branch: "main"

  # Private dependency - fetched separately with auth
  resource "ricochet-core" do
    url "https://github.com/ricochet-rs/ricochet.git",
        revision: "5324123d05be9f1e89c121d7ae446ce037c0f8c7",
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
