using Test: @test_nowarn, @test, @testset
using SHA
using Trixi
using Trixi2Vtk

# pathof(Trixi) returns /path/to/Trixi/src/Trixi.jl, dirname gives the parent directory
const EXAMPLES_DIR = joinpath(pathof(Trixi) |> dirname |> dirname, "examples")


function run_trixi(elixir; parameters...)
  @test_nowarn trixi_include(joinpath(EXAMPLES_DIR, elixir); parameters...)
end


function sha1file(filename)
  open(filename) do f
    bytes2hex(sha1(f))
  end
end


function test_trixi2vtk(filenames, outdir; hashes=nothing, kwargs...)
  @test_nowarn trixi2vtk(joinpath(outdir, filenames); output_directory=outdir, kwargs...)

  if !isnothing(hashes)
    for (filename, hash_expected) in hashes
      hash_measured = sha1file(joinpath(outdir, filename))
      @test_skip hash_expected == hash_measured
    end
  end
end



"""
    @timed_testset "name of the testset" #= code to test #=

Similar to `@testset`, but wraps the execution of the testset using `@time`
and prints the name of the testset after execution.
"""
macro timed_testset(name, expr)
  @assert name isa String
  quote
    @time @testset $name $expr
    flush(stdout)
    @info("Testset " * $name * " finished.\n")
    flush(stdout)
  end
end
