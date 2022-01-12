
include("wordle.jl");

allwords = getwordlist();
numguessesmostpopular  = Dict{String,Int}(answer=>playwordle(answer,algo=MostPopular(),verbose=0)  for answer in allwords);
numguessesexpectedhits = Dict{String,Int}(answer=>playwordle(answer,algo=ExpectedHits(),verbose=0) for answer in allwords);
numguessesEntropyMax   = Dict{String,Int}(answer=>playwordle(answer,algo=EntropyMax(),verbose=0)   for answer in allwords);

# MostPopular results:
results = Accumulator{Int,Int}();
for (key,value) in numguessesmostpopular
    inc!(results,value)
end
resultsTb = sort(DataFrame(numgoes=collect(keys(results)),frequency=collect(values(results))),:numgoes);
println("\nMostPopular results:")
display(resultsTb)
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
=#
meanguesses = round(sum(k*v for (k,v) in results)/sum(v for (k,v) in results),digits=2);
println("\nMean number of guesses = $meanguesses");
# 4.33
# ExpectedHits results:
results = Accumulator{Int,Int}();
for (key,value) in numguessesexpectedhits
    inc!(results,value)
end
resultsTb = sort(DataFrame(numgoes=collect(keys(results)),frequency=collect(values(results))),:numgoes);
println("\nExpectedHits results:")
display(resultsTb)
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
=#
meanguesses = round(sum(k*v for (k,v) in results)/sum(v for (k,v) in results),digits=2);
println("\nMean number of guesses = $meanguesses");
# 3.7

# EntropyMax results:
results = Accumulator{Int,Int}();
for (key,value) in numguessesEntropyMax
    inc!(results,value)
end
resultsTb = sort(DataFrame(numgoes=collect(keys(results)),frequency=collect(values(results))),:numgoes);
println("EntropyMax results:")
display(resultsTb)
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
=#
meanguesses = round(sum(k*v for (k,v) in results)/sum(v for (k,v) in results),digits=2);
println("\nMean number of guesses = $meanguesses");
# 3.57
