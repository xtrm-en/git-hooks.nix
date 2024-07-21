{ config, name, lib, default_stages, ... }:

let
  inherit (lib) concatStringsSep mkOption types;
  mergeExcludes =
    excludes:
    if excludes == [ ] then "^$" else "(${concatStringsSep "|" excludes})";
in
{
  options = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable this pre-commit hook.";
      default = false;
    };

    raw = mkOption {
      type = types.attrsOf types.unspecified;
      description =
        ''
          Raw fields of a pre-commit hook. This is mostly for internal use but
          exposed in case you need to work around something.

          Default: taken from the other hook options.
        '';
    };

    name = mkOption {
      type = types.str;
      defaultText = lib.literalMD "internal name, same as `id`";
      default = name;
      description =
        ''
          The name of the hook. Shown during hook execution.
        '';
    };

    description = mkOption {
      type = types.str;
      description =
        ''
          Description of the hook. Used for metadata purposes only.
        '';
      default = "";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description =
        ''
          An optional package that provides the hook.
        '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description =
        ''
          Additional packages required to run the hook.

          These are propagated to `enabledPackages` for constructing developer
          environments.
        '';
    };

    entry = mkOption {
      type = types.str;
      description =
        ''
          The entry point - the executable to run. {option}`entry` can also contain arguments that will not be overridden, such as `entry = "autopep8 -i";`.
        '';
    };

    language = mkOption {
      type = types.str;
      description =
        ''
          The language of the hook - tells pre-commit how to install the hook.
        '';
      default = "system";
    };

    files = mkOption {
      type = types.str;
      description =
        ''
          The pattern of files to run on.
        '';
      default = "";
    };

    types = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of file types to run on. See [Filtering files with types](https://pre-commit.com/#filtering-files-with-types).
        '';
      default = [ "file" ];
    };

    types_or = mkOption {
      type = types.listOf types.str;
      description =
        ''
          List of file types to run on, where only a single type needs to match.
        '';
      default = [ ];
    };

    excludes = mkOption {
      type = types.listOf types.str;
      description =
        ''
          Exclude files that were matched by these patterns.
        '';
      default = [ ];
    };

    pass_filenames = mkOption {
      type = types.bool;
      description = ''
        Whether to pass filenames as arguments to the entry point.
      '';
      default = true;
    };

    fail_fast = mkOption {
      type = types.bool;
      description = ''
        if true pre-commit will stop running hooks if this hook fails.
      '';
      default = false;
    };

    require_serial = mkOption {
      type = types.bool;
      description = ''
        if true this hook will execute using a single process instead of in parallel.
      '';
      default = false;
    };

    stages = mkOption {
      type = (import ./supported-hooks.nix { inherit lib; }).supportedHooksType;
      description = ''
        Confines the hook to run at a particular stage.
      '';
      default = default_stages;
      defaultText = (lib.literalExpression or lib.literalExample) "default_stages";
    };

    verbose = mkOption {
      type = types.bool;
      default = false;
      description = ''
        forces the output of the hook to be printed even when the hook passes.
      '';
    };

    always_run = mkOption {
      type = types.bool;
      default = false;
      description = ''
        if true this hook will run even if there are no matching files.
      '';
    };
  };

  config = {
    raw =
      {
        inherit (config) name entry language files types types_or pass_filenames fail_fast require_serial stages verbose always_run;
        id = config.name;
        exclude = mergeExcludes config.excludes;
      };
  };
}
