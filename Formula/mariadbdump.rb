class Mariadbdump < Formula
  desc "Standalone mariadb-dump (mysqldump-compatible) client, without the server daemon"
  homepage "https://mariadb.org/"
  url "https://archive.mariadb.org/mariadb-11.8.8/source/mariadb-11.8.8.tar.gz"
  sha256 "bd023a4959faf012db7f0ebfc0d276729e67e5443df193163f98d80fdfc524c9"
  license "GPL-2.0-only"

  bottle do
    root_url "https://github.com/ezintz/homebrew-mariadbdump/releases/download/bottles"
    sha256 arm64_sonoma: "f1b37ddaef8831c719056df438cc0a7000ef5fbac9c803d35b6c05be0968068a"
    sha256 x86_64_linux: "a2adac0a1fb62f60b0815aa736c3df98afbb1f6ad69d908205e73b3cf1bff7cf"
  end

  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl@3"
  depends_on "zstd"

  def install
    args = std_cmake_args + %w[
      -DWITHOUT_SERVER=ON
      -DWITH_UNIT_TESTS=OFF
      -DCOMPILATION_COMMENT=Homebrew-Standalone
    ]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build", "--target", "mariadb-dump"

    bin.install "build/client/mariadb-dump"
    bin.install_symlink "mariadb-dump" => "mysqldump"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mariadb-dump --version")
  end
end
