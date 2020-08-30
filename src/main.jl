function main()
    println("Executing all benchmarks")
    benchmark_downconvert();
    benchmark_carrier_replica();
    benchmark_code_replica();
    benchmark_correlate();
end
