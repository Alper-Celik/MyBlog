---
title: "My First Contributions to nixpkgs and my experiences"
date: 2023-04-21T01
---

in this blogpost i hope to explain my experience of contributing to nixpkgs until this moment

> **Note:** i am not a native english speaker please let me know my mistakes and help me improve my english

# Creating my first package (derivition)

i was working on my [experimental accessibility program][sog-link] when working on accessibility abstraction of it
i wanted to reflect over enums on c++ for looping over enums, doing map lookups, and for printing in program names
of atspi enums for doing theses i wanted to use [magic enum library][magic-enum] for doing these but this wasn't packaged
in nixpkgs unlike my other dependencies so i went ahead and created a simple derivation(package) in my `flake.nix`

```nix
inputs = {
     magic-enum-repo = {
       url = "github:Neargye/magic_enum/v0.8.2";
       flake = false;
     };
}
```

firstly i added magic enum as a flake input and then

```nix
outputs =
...
let
pkgs = nixpkgs.legacyPackages.${system};
magic-enum = pkgs.stdenv.mkDerivation
  {
    pname = "magic-enum"; #1
    version = "0.8.2";

    src = magic-enum-repo; #2

    nativeBuildInputs = with pkgs; [ cmake ]; #3

    doCheck = true; #4
  };
in
...

```

i created a simple derivition:

1. wrote the name and version
2. added source from flake input
3. i added cmake build system as build time dependency
4. enabled tests to be sure library works properly

it was pretty easy to be fair magic enum is pretty trivial to package library it had
cmake install scripts so nix automatically installed it to $out and it didn't had any dependency except c++ compiler
lastly it didn't had any `fetch_content()` calls in cmake so no network sandbox complexity too

since it was easy to package i wanted to upstream it so i looked up how to [contributing guide of nixpkgs][contributing-nixpkgs]
and [contributing section of nixpkgs manual][contributing-nixpkgs-manual] then i forked and shallow cloned nixpkgs

- added myself as maintainer as maintainer and commited to my fork with commit message format required for changes

```nix
...
Alper-Celik = {
    email = "dev.alpercelik@gmail.com";
    name = "Alper Çelik";
    github = "Alper-Celik";
    githubId = 110625473;
    keys = [{
      fingerprint = "6B69 19DD CEE0 FAF3 5C9F  2984 FA90 C0AB 738A B873";
    }];
  };
...
```

- modified derivition to use fetchFromGitHub instead of simpler flake input

```nix
...
  src = fetchFromGitHub {
    owner = "Neargye";
    repo = "magic_enum";
    rev = "v${version}";
    sha256 = "sha256-...";
  };
...
```

- added meta data about package

```nix
...
meta = with lib;{
    description = "Static reflection for enums (to string, from string, iteration) for modern C++";
    homepage = "https://github.com/Neargye/magic_enum";
    license = licenses.mit;
    maintainers = with maintainers; [ Alper-Celik ];
  };
...
```

- lastly navigated (it at least had some organization) `pkgs/top-level/all-packages.nix` for finding correctish spot for package and i found it about at 22.000 th line

```nix
# about 22.000 lines
...
  magic-enum = callPackage ../development/libraries/magic-enum { };
...
# who knows how many lines at the bottom of file
```

and i was ready to create pr for it
i created and waited about a week and @NickCao
pointed out i forget to format package commit message and [recommended formatting package dependencies with [`nixpkgs-fmt`][nixpkgs-fmt].
i was actually using [`nixpkgs-fmt`][nixpkgs-fmt] with [`nul-ls.nvim`][null-ls-nvim], it was actually formatted but when i put one dependency to
other line it expanded and this fixed formatting.
to be fair i was put the formatted the pr message like that and forget to actually format commit message i fixed that.

after fixing problems with pr i thanked @NickCao for reviewing my pr with my _`perfect`_ english.

after about a day later @NickCao merged my pr and i was officially a nixpkgs package maintainer

after a while i backported to 22.11 release because i was using stable release on my `flake.nix` and it got quickly merged by @superherointj too

after some more time i switched to using unstable release system wide instead of having stable and unstable nixos side by side this broked running Qt
info gui when developing because Qt program wasn't wrapped while developing so i updated my `flake.nix` to nixos-unstable too
but then it started to build `magic-enum` instead of fetching from binary cache and failed i guess binary cache failed too and because of that nix tried to build it.
after looking to logs it was about some wide characters (emojis) while building unit tests, after looking into issues tacker of `magic-enum` i saw it was a problem with building on
gcc 12 and unstable releases updating to gcc 12 broked the package, i submitted a pr disabling building of the tests

```nix
# last shape of the pr:

# disable tests until upstream fixes build issues with gcc 12
# see https://github.com/Neargye/magic_enum/issues/235
doCheck = false;
cmakeFlags = [
  "-DMAGIC_ENUM_OPT_BUILD_TESTS=OFF"
];
```

after @wegank helped me with grammar, layout of the sentences and misspellings (he fixed them) he merged the pr.
i will probably enable tests on next version of the library if building tests on the latest compilers gets fixed by then
lastly there was no need to backport this pr since stable(22.11) was still using gcc 11

[nixpkgs-fmt]: https://github.com/nix-community/nixpkgs-fmt
[null-ls-nvim]: https://github.com/jose-elias-alvarez/null-ls.nvim
[contributing-nixpkgs-manual]: https://nixos.org/manual/nixpkgs/stable/#id-1.6
[contributing-nixpkgs]: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md
[sog-link]: https://github.com/Alper-Celik/SoundsOfGuis
[magic-enum]: https://github.com/Neargye/magic_enum
