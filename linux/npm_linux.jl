using RootfsUtils: parse_build_args, upload_gha, test_sandbox
using RootfsUtils: debootstrap

args         = parse_build_args(ARGS, @__FILE__)
arch         = args.arch
archive      = args.archive
image        = args.image

packages = [
    "apt-transport-https",
    "curl",
    "git",
    "locales",
    "npm",
    "vim",
    "wget",
]

artifact_hash, tarball_path, = debootstrap(arch, image; archive, packages)
upload_gha(tarball_path)
test_sandbox(artifact_hash)
