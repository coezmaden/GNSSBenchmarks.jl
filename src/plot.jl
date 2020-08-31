function plot_carrier_replica()
    println("Plotting the carrier replica benhcmarks...")
    data = DataFrame!(CSV.File("data/carrier_replica.csv"))
    plot(
        data.Samples,
        [data.GPU_median,data.sCPU_median],
        title = "Benchmark carrier_replica!()",
        label=["GPU" "CPU"],
        xlabel="Samples",
        ylabel="Zeit/ns"
    )
    savefig("plots/carrier_replica.png")
    println("Saved the carrier_replica plot under /plots")
end

function plot_downconvert()
    println("Plotting the downconvert benhcmarks...")
    data = DataFrame!(CSV.File("data/downconvert.csv"))
    plot(
        data.Samples,
        [data.GPU_median,data.sCPU_median],
        title = "Benchmark donwconvert!()",
        label=["GPU" "CPU"],
        xlabel="Samples",
        ylabel="Zeit/ns"
    )
    savefig("plots/donwconvert.png")
    println("Saved the downconvert plot under /plots")
end

function plot_correlate()
    println("Plotting the correlation benhcmarks...")
    data = DataFrame!(CSV.File("data/correlate.csv"))
    plot(
        data.Samples,
        [data.GPU_median,data.sCPU_median],
        title = "Benchmark correlate!()",
        label=["GPU" "CPU"],
        xlabel="Samples",
        ylabel="Zeit/ns"
    )
    savefig("plots/correlate.png")
    println("Saved the correlations plot under /plots")
end

function plot_code_replica()
    println("Plotting the code_replica benhcmarks...")
    data = DataFrame!(CSV.File("data/code_replica.csv"))
    plot(
        data.Samples,
        [data.GPU_median,data.CPU_median],
        title = "Benchmark code_replica!()",
        label=["GPU" "CPU"],
        xlabel="Samples",
        ylabel="Zeit/ns"
    )
    savefig("plots/code_replica.png")
    println("Saved the code_replica plot under /plots")
end

