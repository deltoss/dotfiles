use ./helpers/add-path-env.nu

winget install MSYS2.MSYS2 --accept-package-agreements --accept-source-agreements

# Install clang from MSYS2's MinGW toolchain. Unlike standalone LLVM, it bundles
# GNU C standard library headers (e.g. stdlib.h), making it self-contained
# without depending on MSVC or the Windows SDK.
C:\msys64\usr\bin\bash.exe -lc "pacman -S --noconfirm mingw-w64-x86_64-clang"

let mingw_dir = $"C:\\msys64\\mingw64\\bin"
add-path-env $mingw_dir