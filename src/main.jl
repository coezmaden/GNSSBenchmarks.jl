function main()
    println("Executing all benchmarks")
    benchmark_downconvert();
    benchmark_carrier_replica();
    benchmark_code_replica();
    benchmark_correlate();
end

function plotall()
    println("Plotting all the .csv benchmarks under /data ...")
    plot_carrier_replica()
end