function plot_carrier_replica()
    println("Plotting the carrier replica benhcmarks...")
    data = DataFrame!(CSV.File("data/carrierreplica.csv"))
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Samples",
            ylabel = "Zeit / us",
            title = "Zeit für carrierreplica mit einer Antenne",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "north west"
            },
            PlotInc({
                blue,
                mark="|",
                thin
            }, 
            Coordinates(data.Samples, data.sCPU_median)),
            PlotInc({
                red,
                mark="x",
                thin
            },
            Coordinates(data.Samples, data.GPU_median)),
            Legend(["CPU median","GPU median"])
        )
    )
    pgfsave("plots/carrierreplica.tex", pgfplot) 
    pgfsave("plots/carrierreplica.png", pgfplot, dpi = 300)
    println("Saved the carrierreplica plot under /plots")
end

function plot_downconvert_cpu_gpu(data=DataFrame!(CSV.File("data/downconvert.csv")), targetdirtex="plots/downconvert.tex", targetdirpng="plots/downconvert.png")
    println("Plotting the downconvert benhcmarks...")
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Samples",
            ylabel = "Zeit / s",
            ymode = "log",
            title = "Zeit für downconvert",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "north west",
            },
            PlotInc({
                blue,
                mark="|",
                thin
            }, Coordinates(data.Samples, 10^(-9)*data.sCPU_median_1ant)),
            PlotInc({
                blue,
                mark="|",
                thin
            }, Coordinates(data.Samples, 10^(-9)*data.sCPU_median_4ant)),
            PlotInc({
                blue,
                mark="|",
                thin
            }, Coordinates(data.Samples, 10^(-9)*data.sCPU_median_16ant)),
            PlotInc({
                red,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.GPU_median_1ant)),
            PlotInc({
                red,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.GPU_median_4ant)),
            PlotInc({
                red,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.GPU_median_16ant)),
            # PlotInc({
            #     gray,
            #     mark="|",
            #     thin
            # },Coordinates(data.Samples, 10^(-9)*data.sGPU_median_1ant)),
            # PlotInc({
            #     gray,
            #     mark="|",
            #     thin
            # },Coordinates(data.Samples, 10^(-9)*data.sGPU_median_4ant)),
            # PlotInc({
            #     gray,
            #     mark="|",
            #     thin
            # },Coordinates(data.Samples, 10^(-9)*data.sGPU_median_16ant)),
            Legend([
            "CPU median Ant=1","CPU median Ant=4","CPU median Ant=16",
            "GPU median Ant=1","GPU median Ant=4","GPU median Ant=16",
            #"sGPU median Ant=1","sGPU median Ant=4","sGPU median Ant=16"
            ])
        )
    )
    pgfsave(targetdirtex, pgfplot) 
    pgfsave(targetdirpng, pgfplot, dpi = 300)
    println("Saved the downconvert plot under", targetdirtex)
end

function plot_downconvert_gpu_gpu(data=DataFrame!(CSV.File("data/downconvert.csv")), targetdirtex="plots/downconvert.tex", targetdirpng="plots/downconvert.png")
    println("Plotting the downconvert benhcmarks...")
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Samples",
            ylabel = "Zeit / s",
            ymode = "log",
            title = "Zeit für downconvert",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "outer north east",
            },
            PlotInc({
                red,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.GPU_median_1ant)),
            PlotInc({
                red,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.GPU_median_4ant)),
            PlotInc({
                red,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.GPU_median_16ant)),
            PlotInc({
                gray,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.sGPU_median_1ant)),
            PlotInc({
                gray,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.sGPU_median_4ant)),
            PlotInc({
                gray,
                mark="|",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.sGPU_median_16ant)),
            Legend([
            # "CPU median Ant=1","CPU median Ant=4","CPU median Ant=16",
            "GPU median Ant=1","GPU median Ant=4","GPU median Ant=16",
            "sGPU median Ant=1","sGPU median Ant=4","sGPU median Ant=16"
            ])
        )
    )
    pgfsave(targetdirtex, pgfplot) 
    pgfsave(targetdirpng, pgfplot, dpi = 300)
    println("Saved the downconvert plot under", targetdirtex)
end

function plot_correlate()
    println("Plotting the correlation benhcmarks...")
    data = DataFrame!(CSV.File("data/correlate.csv"))
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Samples",
            ylabel = "Zeit / us",
            title = "Zeit für correlate mit einer Antenne",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "north west"
            },
            PlotInc({
                blue,
                mark="|",
                thin
            }, 
            Coordinates(data.Samples, data.sCPU_median)),
            PlotInc({
                red,
                mark="x",
                thin
            },
            Coordinates(data.Samples, data.GPU_median)),
            Legend(["CPU median","GPU median"])
        )
    )
    pgfsave("plots/correlate.tex", pgfplot) 
    pgfsave("plots/correlate.png", pgfplot, dpi = 300)
    println("Saved the correlations plot under /plots")
end

function plot_code_replica()
    println("Plotting the codereplica benhcmarks...")
    data = DataFrame!(CSV.File("data/codereplica.csv"))
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Samples",
            ylabel = "Zeit / us",
            title = "Zeit für codereplica mit einer Antenne",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "north west"
            },
            PlotInc({
                blue,
                mark="|",
                thin
            }, 
            Coordinates(data.Samples, data.CPU_median)),
            PlotInc({
                red,
                mark="x",
                thin
            },
            Coordinates(data.Samples, data.GPU_median)),
            Legend(["CPU median","GPU median"])
        )
    )
    pgfsave("plots/codereplica.tex", pgfplot) 
    pgfsave("plots/codereplica.png", pgfplot, dpi = 300)
    println("Saved the codereplica plot under /plots")
end

