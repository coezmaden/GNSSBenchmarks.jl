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

function plot_downconvert()
    println("Plotting the downconvert benhcmarks...")
    data = DataFrame!(CSV.File("data/downconvert.csv"))
    pgfplot = @pgf TikzPicture(
        Axis({
            xlabel = "Samples",
            ylabel = "Zeit / us",
            title = "Zeit für downconvert mit einer Antenne",
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
    pgfsave("plots/downconvert.tex", pgfplot) 
    pgfsave("plots/downconvert.png", pgfplot, dpi = 300)
    println("Saved the downconvert plot under /plots")
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

