
include("wordle.jl");

allwords = getwordsfreqorder();
numguessesexpectedhits = Dict{String,Int}(answer=>playwordle(answer,algo=ExpectedHits(false)) for answer in allwords);
numguessesentropymin   = Dict{String,Int}(answer=>playwordle(answer,algo=EntropyMin(false))   for answer in allwords);

# ExpectedHits results:
results = Accumulator{Int,Int}();
for (key,value) in numguessesexpectedhits
    inc!(results,value)
end
resultsTb = sort(DataFrame(numgoes=collect(keys(results)),frequency=collect(values(results))),:numgoes)
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
sum(k*v for (k,v) in results)/sum(v for (k,v) in results)
# 3.7

# EntropyMin results:
results = Accumulator{Int,Int}();
for (key,value) in numguessesentropymin
    inc!(results,value)
end
resultsTb = sort(DataFrame(numgoes=collect(keys(results)),frequency=collect(values(results))),:numgoes)
#=
 Row │ numgoes  frequency 
     │ Int64    Int64     
─────┼────────────────────
   1 │       1          1
   2 │       2        165
   3 │       3       1224
   4 │       4       1104
   5 │       5        236
   6 │       6         45
   7 │       7         12
   8 │       8          3
   9 │       9          1
=#
sum(k*v for (k,v) in results)/sum(v for (k,v) in results)
# 3.58

