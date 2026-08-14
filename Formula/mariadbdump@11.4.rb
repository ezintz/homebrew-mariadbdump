class MariadbdumpAT114 < Formula
  desc "Standalone mariadb-dump (mysqldump-compatible) client, MariaDB 11.4"
  homepage "https://mariadb.org/"
  url "https://archive.mariadb.org/mariadb-11.4.12/source/mariadb-11.4.12.tar.gz"
  sha256 "5ab7883db519bfcebfdd2aac09bc5544a12ce328f39edd46d0bf01690615ef6c"
  license "GPL-2.0-only"

  keg_only :versioned_formula

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
