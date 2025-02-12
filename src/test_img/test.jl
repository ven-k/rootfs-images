function test_sandbox(artifact_hash)
    test_cmd = `$(Base.julia_cmd())`
    append!(test_cmd.exec, String[
        "--project=$(Base.active_project())",
        joinpath(dirname(dirname(@__DIR__)), "test_rootfs.jl"),
        "--map-build-dir=temp",
        "--treehash=$(artifact_hash)",
        "--",
        "/bin/bash", "-c", "echo Hello from inside the sandbox",
    ])
    @testset "Test sandbox" begin
        @testset begin
            run(test_cmd)
        end
        @testset begin
            @test success(test_cmd)
            @test read(test_cmd, String) == "Hello from inside the sandbox\n"
        end
    end
    return nothing
end

function ensure_artifact_exists_locally(; treehash, url)
    if !Pkg.Artifacts.artifact_exists(treehash)
        if url === nothing
            error_msg = "The artifact does not exist locally, so you must provide the URL."
            throw(ArgumentError(error_msg))
        end
        @info("Artifact did not exist locally, downloading")
        was_success = Pkg.Artifacts.download_artifact(treehash, url; verbose=true)
        was_success || throw(ErrorException("Download was not a success"))
    end
    Pkg.Artifacts.artifact_exists(treehash) || throw(ErrorException("Could not download the artifact"))
    return nothing
end
