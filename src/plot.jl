function plot_carrier_replica()
    data = DataFrame!(CSV.File("data/carrier_replica.csv"))
    plot(
        data.Samples,
        [data.GPU_median,data.sCPU_median],
        title = "Benchmark carrier_replica!()",
        label=["GPU" "CPU"],
        xlabel="Samples",
        ylabel="Zeit/ns"
    )
end

