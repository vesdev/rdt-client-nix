{ lib
, buildNpmPackage
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, jq
, appSettings ? { }
}:
let
  src = fetchFromGitHub {
    owner = "rogerfar";
    repo = "rdt-client";
    rev = "v${version}";
    sha256 = "sha256-WUYeEFolOQ+IQ19kbGxbTDILyuuGKGnKF8xeF4CDO4E=";
  };

  version = "2.0.102";
  client = buildNpmPackage {
    pname = "rdt-client-wwwroot";
    inherit version;
    src = "${src}/client";
    npmDepsHash = "sha256-9+bJ9UMDgz8rfpwGKAbo1uxqF/e/mQW01k5BmG4ou6w=";

    preBuild = ''
      mv angular.json angular.json.old
      ${jq}/bin/jq '.projects.client.architect.build.options.outputPath.base = "./wwwroot"' angular.json.old > angular.json
    '';

    installPhase = ''
      cp -r wwwroot $out/
    '';
  };
in
buildDotnetModule rec {
  pname = "RdtClient.Web";
  inherit version src;

  projectFile = "server/RdtClient.sln";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_9_0-bin;
  dotnet-runtime = dotnetCorePackages.runtime_9_0-bin;
  selfContainedBuild = true;
  dotnetBuildFlags = [ "--no-incremental" ];

  executables = [ "RdtClient.Web" ];

  makeWrapperArgs = [
    "--set DOTNET_CONTENTROOT ${placeholder "out"}/lib/${pname}"
  ];

  postInstall =
    ''
      echo '${builtins.toJSON appSettings}' > $out/lib/${pname}/appsettings.json
      ln -s ${client} $out/lib/${pname}/wwwroot
    '';

  meta = with lib; {
    homepage = "https://github.com/rogerfar/rdt-client";
    description = " Real-Debrid Client Proxy";
    license = licenses.mit;
  };
}

