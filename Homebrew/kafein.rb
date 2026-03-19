class Kafein < Formula
  desc "Minimalist macOS menu bar app to prevent sleep"
  homepage "https://github.com/ohtufan/kafein"
  url "https://github.com/ohtufan/kafein/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6f7e75d65cd82fa69b436cb690257facb2a6bc62b263e874515c0224ab8b692b"
  license "MIT"

  depends_on xcode: ["15.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    app_bundle = "#{prefix}/Kafein.app/Contents"
    mkdir_p "#{app_bundle}/MacOS"
    mkdir_p "#{app_bundle}/Resources"

    cp ".build/release/Kafein", "#{app_bundle}/MacOS/Kafein"
    cp "Resources/Info.plist", "#{app_bundle}/"
  end

  def caveats
    <<~EOS
      Kafein is an unsigned app. On first launch:
        Right-click Kafein.app → Open → Open

      To start Kafein:
        open #{prefix}/Kafein.app
    EOS
  end

  test do
    system "swift", "build"
  end
end
