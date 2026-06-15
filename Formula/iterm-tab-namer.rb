class ItermTabNamer < Formula
  include Language::Python::Virtualenv

  desc     "Auto-rename iTerm2 tabs from their content using Apple's on-device model"
  homepage "https://github.com/EnjoyBacon7/iterm-tab-namer"
  url      "https://github.com/EnjoyBacon7/iterm-tab-namer/archive/refs/tags/v0.1.0.tar.gz"
  sha256   "3d46ec5267d2edcb3e29aecfd5bf4047c9f4d742518e6a41176e6034db8d40b7"
  license  "MIT"

  depends_on arch: :arm64        # on-device model is Apple Silicon only
  depends_on macos: :tahoe       # FoundationModels requires macOS 26+
  depends_on "python@3.13"

  resource "iterm2" do
    url "https://files.pythonhosted.org/packages/4f/fb/258e7e3bfcacf9cdfc378ae4ee2aca743dbccd6a12ffceee12957f67dff3/iterm2-2.20.tar.gz"
    sha256 "168d3807cd58b3e678476852be2bb4a5cd89f008d95e37d2777d9810731cff08"
  end

  resource "protobuf" do
    url "https://files.pythonhosted.org/packages/da/01/9ef0afd7999eb9badb3a768b4aedd78c86d4c65cfaf1958ab276199e76b4/protobuf-7.35.1.tar.gz"
    sha256 "ce115a26fe0c39a2c29973d914d327e516a6455464489fe3cd1e51a1b354f81a"
  end

  resource "websockets" do
    url "https://files.pythonhosted.org/packages/04/24/4b2031d72e840ce4c1ccb255f693b15c334757fc50023e4db9537080b8c4/websockets-16.0.tar.gz"
    sha256 "5f6261a5e56e8d5c42a4497b364ea24d94d9563e8fbd44e78ac40879c60179b5"
  end

  def install
    system "swiftc", "-O", "tabnamer.swift", "-o", "tabnamer"
    libexec.install "tabnamer", "tab_namer.py"
    venv = virtualenv_create(libexec/"venv", "python3.13")
    venv.pip_install resources
    (bin/"iterm-tab-namer").write <<~SH
      #!/bin/bash
      exec "#{libexec}/venv/bin/python" "#{libexec}/tab_namer.py" "$@"
    SH
  end

  service do
    run [opt_bin/"iterm-tab-namer"]
    keep_alive true
    log_path       var/"log/iterm-tab-namer.log"
    error_log_path var/"log/iterm-tab-namer.log"
  end

  def caveats
    <<~EOS
      One-time setup in iTerm2:
        1. Settings > General > Magic > enable "Python API"
        2. iTerm2 menu > Install Shell Integration
        3. Restart iTerm2, then click Allow when it asks to control iTerm2.
      Start it at login:
        brew services start iterm-tab-namer
    EOS
  end

  test do
    assert_path_exists libexec/"tabnamer"
  end
end
