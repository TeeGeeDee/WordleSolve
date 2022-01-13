using StatsPlots

include("wordle.jl");

function summariseresults(algo::GreedyAlgo)
    numguesses  = Dict{String,Int}(answer=>playwordle(answer,algo=algo,verbose=0)  for answer in getwordlist());
    results = Accumulator{Int,Int}();
    for value in values(numguesses)
        inc!(results,value)
    end
    resultstb = sort(DataFrame(numgoes=collect(keys(results)),frequency=round.(100*collect(values(results))./sum(values(results)),digits=1)),:numgoes);
    resultstb.cumfreq = round.(cumsum(resultstb.frequency),digits=3);
    println("\nMostPopular results:")
    display(resultstb)
    meanguesses = round(sum(k*v for (k,v) in results)/sum(v for (k,v) in results),digits=2);
    println("\nMean number of guesses = $meanguesses");
    println("Failure rate = $(round(100-resultstb.cumfreq[6],digits=1))%");
    return resultstb
end


alltbs = OrderedDict{String,DataFrame}();
# MostPopular results:
alltbs["MostPopular"] = summariseresults(MostPopular());
#=
 Row │ numgoes  frequency 
     │ Int64    Int64     
─────┼────────────────────
   1 │       1          1
   2 │       2         55
   3 │       3        468
   4 │       4       1149
   5 │       5        814
   6 │       6        239
   7 │       7         54
   8 │       8          9
   9 │       9          2

Mean number of guesses = 4.33
Failure rate = 2.3%
=#

# ExpectedHits results:
alltbs["ExpectedHits"]  = summariseresults(ExpectedHits());

#=
 Row │ numgoes  frequency 
     │ Int64    Int64     
─────┼────────────────────
   1 │       1          1
   2 │       2        155
   3 │       3       1028
   4 │       4       1176
   5 │       5        362
   6 │       6         59
   7 │       7          7
   8 │       8          1
   9 │       9          1
  10 │      10          1

Mean number of guesses = 3.7
Failure rate = 0.4%
=#

# EntropyMax results:
alltbs["EntropyMax"] = summariseresults(EntropyMax());

#=
 Row │ numgoes  frequency 
     │ Int64    Int64     
─────┼────────────────────
   1 │       1          1
   2 │       2        165
   3 │       3       1226
   4 │       4       1105
   5 │       5        237
   6 │       6         43
   7 │       7         10
   8 │       8          3
   9 │       9          1

Mean number of guesses = 3.57
Failure rate = 0.5%
=#

# MiniMax results:
alltbs["MiniMax"] = summariseresults(MiniMax());

#=
 Row │ numgoes  frequency 
     │ Int64    Int64     
─────┼────────────────────
   1 │       1          1
   2 │       2        143
   3 │       3       1043
   4 │       4       1183
   5 │       5        336
   6 │       6         65
   7 │       7         14
   8 │       8          4
   9 │       9          1
  10 │      10          1

Mean number of guesses = 3.71
Failure rate = 0.7%
=#

# We can be pretty bad if we want to be:
# EntropyMin results:
alltbs["EntropyMin"] = summariseresults(EntropyMin());

#=
 Row │ numgoes  frequency  cumfreq 
     │ Int64    Int64      Float64 
─────┼─────────────────────────────
   1 │       1          1    0.0
   2 │       2         33    0.012
   3 │       3        148    0.065
   4 │       4        381    0.202
   5 │       5        587    0.412
   6 │       6        707    0.665
   7 │       7        553    0.863
   8 │       8        261    0.957
   9 │       9         89    0.989
  10 │      10         26    0.998
  11 │      11          4    1.0
  12 │      12          1    1.0

Mean number of guesses = 5.84
Failure rate = 33.5%
=#
meangoes = [k*" (mean goes = $(round(sum(v.numgoes.*v.frequency/100),digits=2)))" for (k,v) in alltbs];
len = maximum(size(t,1) for t in values(alltbs));
cumfreqs = reduce(vcat,[[tb.cumfreq;100*ones(len-size(tb,1))]' for tb in values(alltbs)])';
plot(cumfreqs,label=permutedims(meangoes),xlabel="Number of goes",ylabel="Cumulative % of wins",
xticks=1:len,legend=:bottomright,yticks=0:10:100,title="Performance of algorithms across all answers")
