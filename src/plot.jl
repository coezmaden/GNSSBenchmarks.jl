function plot_carrier_replica(data=DataFrame!(CSV.File("data/carrier_replica.csv")), targetdirtex="plots/carrier_replica.tex", targetdirpng="plots/carrier_replica.png")
    println("Plotting the carrier replica benhcmarks...")
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Samples",
            ylabel = "Zeit / us",
            ymode = "log",
            title = "Zeit für carrierreplica mit einer Antenne",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "outer north east"
            },
            PlotInc({
                blue,
                mark="|",
                thin
            }, Coordinates(data.Samples, 10^(-9)*data.sCPU_time)),
            PlotInc({
                red,
                mark="x",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.GPU_time)),
            PlotInc({
                green,
                mark="x",
                thin
            },Coordinates(data.Samples, 10^(-9)*data.sGPU_time)),
            Legend(["CPU","GPU","sGPU"])
        )
    )
    pgfsave(targetdirtex, pgfplot) 
    pgfsave(targetdirpng, pgfplot, dpi = 300)
    println("Saved the carrierreplica plot under ", targetdirtex)
end

function plot_carrier_replica_all(
    datamin=DataFrame!(CSV.File("data/carrierreplica_min.csv")),
    datamed=DataFrame!(CSV.File("data/carrierreplica_med.csv")),
    datamean=DataFrame!(CSV.File("data/carrierreplica_mean.csv")),
    targetdirtex="plots/carrierreplica_all.tex", 
    targetdirpng="plots/carrierreplica_all.png"
)
    println("Plotting the carrier replica benhcmarks...")
    push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\usepgfplotslibrary{fillbetween}")
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Abtwastwerte",
            ylabel = "Zeit / s",
            ymode = "log",
            title = "Laufzeit der gencarrierreplica!",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "outer north east"
            },
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmin",
                style ="{solid}",
            }, Coordinates(datamin.Samples, 10^(-9)*datamin.sCPU_time)),
            PlotInc({
                blue,
                mark="x",
                thin,
                style ="{dashed}",
            }, Coordinates(datamed.Samples, 10^(-9)*datamed.sCPU_time)),
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmean",
                style ="{dotted}",
            }, Coordinates(datamean.Samples, 10^(-9)*datamean.sCPU_time)),
            PlotInc({
                thick, 
                color = "blue", 
                fill = "blue", 
                opacity = 0.2 },
            raw"fill between [of=CPUmin and CPUmean]"),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmin",
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.GPU_time)),
            PlotInc({
                red,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(datamed.Samples, 10^(-9)*datamed.GPU_time)),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmean",
                style ="{dotted}",
            },Coordinates(datamean.Samples, 10^(-9)*datamean.GPU_time)),
            PlotInc({
                thick, 
                color = "red", 
                fill = "red", 
                opacity = 0.2 },
            raw"fill between [of=GPUmin and GPUmean]"),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmin",
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.sGPU_time)),
            PlotInc({
                green,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(datamed.Samples, 10^(-9)*datamed.sGPU_time)),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmean",
                style ="{dotted}",
            },Coordinates(datamean.Samples, 10^(-9)*datamean.sGPU_time)),
            PlotInc({
                thick, 
                color = "green", 
                fill = "green", 
                opacity = 0.2 },
            raw"fill between [of=sGPUmin and sGPUmean]"),
            Legend([
                "StructArray CPU Minimum", "StructArray CPU Median", "StructArray CPU Mean", "",
                "CuArray GPU Minimum", "CuArray GPU Median", "CuArray GPU Mean", "",
                "StructArray GPU Minimum", "StructArray GPU Median", "StructArray GPU Mean", ""])
        )
    )
    pgfsave(targetdirtex, pgfplot) 
    pgfsave(targetdirpng, pgfplot, dpi = 300)
    println("Saved the carrierreplica plot")
end

function plot_downconvert(data=DataFrame!(CSV.File("data/downconvert.csv")), targetdirtex="plots/downconvert.tex", targetdirpng="plots/downconvert.png")
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

function plot_downconvert_all(
    datamin=DataFrame!(CSV.File("data/carrierreplica_min.csv")),
    datamed=DataFrame!(CSV.File("data/carrierreplica_med.csv")),
    datamean=DataFrame!(CSV.File("data/carrierreplica_mean.csv")),
    targetdirtex="plots/carrierreplica_all.tex", 
    targetdirpng="plots/carrierreplica_all.png"
)
    println("Plotting the carrier replica benhcmarks...")
    push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\usepgfplotslibrary{fillbetween}")
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Abtwastwerte",
            ylabel = "Zeit / s",
            ymode = "log",
            title = "Laufzeit der donwconvert!",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "outer north east"
            },
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmin1ant",
                style ="{solid}",
            }, Coordinates(data.Samples, 10^(-9)*datamin.sCPU_time_1ant)),
            PlotInc({
                blue,
                mark="x",
                thin,
                style ="{dashed}",
            }, Coordinates(data.Samples, 10^(-9)*datamed.sCPU_time_1ant)),
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmean1ant",
                style ="{dotted}",
            }, Coordinates(data.Samples, 10^(-9)*datamean.sCPU_time_1ant)),
            PlotInc({
                thick, 
                color = "blue", 
                fill = "blue", 
                opacity = 0.2 },
            raw"fill between [of=CPUmin1ant and CPUmean1ant]"),
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmin4ant",
                style ="{solid}",
            }, Coordinates(data.Samples, 10^(-9)*datamin.sCPU_time_4ant)),
            PlotInc({
                blue,
                mark="x",
                thin,
                style ="{dashed}",
            }, Coordinates(data.Samples, 10^(-9)*datamed.sCPU_time_4ant)),
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmean4ant",
                style ="{dotted}",
            }, Coordinates(data.Samples, 10^(-9)*datamean.sCPU_time_4ant)),
            PlotInc({
                thick, 
                color = "blue", 
                fill = "blue", 
                opacity = 0.2 },
            raw"fill between [of=CPUmin4ant and CPUmean4ant]"),
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmin16ant",
                style ="{solid}",
            }, Coordinates(data.Samples, 10^(-9)*datamin.sCPU_time_16ant)),
            PlotInc({
                blue,
                mark="x",
                thin,
                style ="{dashed}",
            }, Coordinates(data.Samples, 10^(-9)*datamed.sCPU_time_16ant)),
            PlotInc({
                blue,
                mark="x",
                thin,
                "name path=CPUmean16ant",
                style ="{dotted}",
            }, Coordinates(data.Samples, 10^(-9)*datamean.sCPU_time_16ant)),
            PlotInc({
                thick, 
                color = "blue", 
                fill = "blue", 
                opacity = 0.2 },
            raw"fill between [of=CPUmin16ant and CPUmean16ant]"),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmin1ant",
                style ="{solid}",
            },Coordinates(data.Samples, 10^(-9)*datamin.GPU_time_1ant)),
            PlotInc({
                red,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(data.Samples, 10^(-9)*datamed.GPU_time_1ant)),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmean1ant",
                style ="{dotted}",
            },Coordinates(data.Samples, 10^(-9)*datamean.GPU_time_1ant)),
            PlotInc({
                thick, 
                color = "red", 
                fill = "red", 
                opacity = 0.2 },
            raw"fill between [of=GPUmin1ant and GPUmean1ant]"),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmin4ant",
                style ="{solid}",
            },Coordinates(data.Samples, 10^(-9)*datamin.GPU_time_4ant)),
            PlotInc({
                red,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(data.Samples, 10^(-9)*datamed.GPU_time_4ant)),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmean4ant",
                style ="{dotted}",
            },Coordinates(data.Samples, 10^(-9)*datamean.GPU_time_4ant)),
            PlotInc({
                thick, 
                color = "red", 
                fill = "red", 
                opacity = 0.2 },
            raw"fill between [of=GPUmin4ant and GPUmean4ant]"),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmin16ant",
                style ="{solid}",
            },Coordinates(data.Samples, 10^(-9)*datamin.GPU_time_16ant)),
            PlotInc({
                red,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(data.Samples, 10^(-9)*datamed.GPU_time_16ant)),
            PlotInc({
                red,
                mark="x",
                thin,
                "name path=GPUmean16ant",
                style ="{dotted}",
            },Coordinates(data.Samples, 10^(-9)*datamean.GPU_time_16ant)),
            PlotInc({
                thick, 
                color = "red", 
                fill = "red", 
                opacity = 0.2 },
            raw"fill between [of=GPUmin16ant and GPUmean16ant]"),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmin1ant",
                style ="{solid}",
            },Coordinates(data.Samples, 10^(-9)*datamin.sGPU_time_1ant)),
            PlotInc({
                green,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(data.Samples, 10^(-9)*datamed.sGPU_time_1ant)),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmean1ant",
                style ="{dotted}",
            },Coordinates(data.Samples, 10^(-9)*datamean.sGPU_time_1ant)),
            PlotInc({
                thick, 
                color = "green", 
                fill = "green", 
                opacity = 0.2 },
            raw"fill between [of=sGPUmin1ant and sGPUmean1ant]"),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmin4ant",
                style ="{solid}",
            },Coordinates(data.Samples, 10^(-9)*datamin.sGPU_time_4ant)),
            PlotInc({
                green,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(data.Samples, 10^(-9)*datamed.sGPU_time_4ant)),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmean4ant",
                style ="{dotted}",
            },Coordinates(data.Samples, 10^(-9)*datamean.sGPU_time_4ant)),
            PlotInc({
                thick, 
                color = "green", 
                fill = "green", 
                opacity = 0.2 },
            raw"fill between [of=sGPUmin4ant and sGPUmean4ant]"),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmin16ant",
                style ="{solid}",
            },Coordinates(data.Samples, 10^(-9)*datamin.sGPU_time_16ant)),
            PlotInc({
                green,
                mark="x",
                thin,
                style ="{dashed}",
            },Coordinates(data.Samples, 10^(-9)*datamed.sGPU_time_16ant)),
            PlotInc({
                green,
                mark="x",
                thin,
                "name path=sGPUmean16ant",
                style ="{dotted}",
            },Coordinates(data.Samples, 10^(-9)*datamean.sGPU_time_16ant)),
            PlotInc({
                thick, 
                color = "green", 
                fill = "green", 
                opacity = 0.2 },
            raw"fill between [of=sGPUmin16ant and sGPUmean16ant]"),
            Legend([
                "StructArray CPU Minimum Ant=1", "StructArray CPU Median Ant=1", "StructArray CPU Mean Ant=1", "",
                "StructArray CPU Minimum Ant=4", "StructArray CPU Median Ant=4", "StructArray CPU Mean Ant=4", "",
                "StructArray CPU Minimum Ant=16", "StructArray CPU Median Ant=16", "StructArray CPU Mean Ant=16", "",
                "CuArray GPU Minimum Ant=1", "CuArray GPU Median Ant=1", "CuArray GPU Mean Ant=1", "",
                "CuArray GPU Minimum Ant=4", "CuArray GPU Median Ant=4", "CuArray GPU Mean Ant=4", "",
                "CuArray GPU Minimum Ant=16", "CuArray GPU Median Ant=16", "CuArray GPU Mean Ant=16", "",
                "StructArray GPU Minimum Ant=1", "StructArray GPU Median Ant=1", "StructArray GPU Mean Ant=1", "",
                "StructArray GPU Minimum Ant=4", "StructArray GPU Median Ant=4", "StructArray GPU Mean Ant=4", "",
                "StructArray GPU Minimum Ant=16", "StructArray GPU Median Ant=16", "StructArray GPU Mean Ant=16", ""])
        )
    )
    pgfsave(targetdirtex, pgfplot) 
    pgfsave(targetdirpng, pgfplot, dpi = 300)
    println("Saved the downconvert plot")
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

function plot_correlate_all(
    datamin=DataFrame!(CSV.File("data/correlate_min.csv"))
)   
push!(PGFPlotsX.CUSTOM_PREAMBLE, raw"\usepgfplotslibrary{fillbetween}")
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Abtwastwerte",
            ylabel = "Programmlaufzeit [s]",
            ymode = "log",
            title = "correlate",
            xmajorgrids,
            ymajorgrids,
            scaled_ticks = "false",
            legend_pos = "outer north east"
            },
            PlotInc({
                cyan,
                mark="x",
                thin,
                style ="{solid}",
            }, Coordinates(datamin.Samples, 10^(-9)*datamin.sCPU_time_1ant)),
            PlotInc({
                teal,
                mark="x",
                thin,
                style ="{solid}",
            }, Coordinates(datamin.Samples, 10^(-9)*datamin.sCPU_time_4ant)),
            PlotInc({
                blue,
                mark="x",
                thin,
                style ="{solid}",
            }, Coordinates(datamin.Samples, 10^(-9)*datamin.sCPU_time_16ant)),
            PlotInc({
                color="magenta",
                mark="x",
                thin,
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.GPU_time_1ant)),
            PlotInc({
                color="red",
                mark="x",
                thin,
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.GPU_time_4ant)),
            PlotInc({
                color="violet",
                mark="x",
                thin,
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.GPU_time_16ant)),
            PlotInc({
                color="lime",
                mark="x",
                thin,
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.sGPU_time_1ant)),
            PlotInc({
                color="green",
                mark="x",
                thin,
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.sGPU_time_4ant)),
            PlotInc({
                color="green!50!black",
                mark="x",
                thin,
                style ="{solid}",
            },Coordinates(datamin.Samples, 10^(-9)*datamin.sGPU_time_16ant)),
            Legend([
                "StructArray CPU Minimum Ant=1",
                "StructArray CPU Minimum Ant=4",
                "StructArray CPU Minimum Ant=16",
                "CuArray GPU Minimum Ant=1",
                "CuArray GPU Minimum Ant=4",
                "CuArray GPU Minimum Ant=16",
                "StructArray GPU Minimum Ant=1",
                "StructArray GPU Minimum Ant=4",
                "StructArray GPU Minimum Ant=16"])
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

