using DataStructures
using DataFrames
using Statistics
using StatsBase
using Memoization

@enum Output ⬜ 🟨 🟩;
const WORD_LENGTH = 5;
const WordList = Vector{String};

abstract type GreedyAlgo end
struct ExpectedHits <: GreedyAlgo end
struct EntropyMax   <: GreedyAlgo end
struct MiniMax   <: GreedyAlgo end
struct MostPopular  <: GreedyAlgo end

function playwordle(answer::String;interactive::Bool=false,withhelp::Bool=false,algo::GreedyAlgo=EntropyMax(),verbose::Int=1)::Int
    @assert length(answer)==WORD_LENGTH;
    @assert all(islowercase(c) for c in answer);
    if verbose>0 println("LET'S PLAY WORDLE"* (interactive ? "" : " (ANSWER IS \"$answer\")")); end
    wordlist = getwordlist();
    output,go = fill(⬜,WORD_LENGTH),0;
    outputall = Vector{Vector{Output}}();
    while !all(output.==🟩)
        go += 1;
        if verbose>0 println("\n ****** Go $go ******"); end
        if !interactive || withhelp
            guess = nextguess(algo,wordlist,printworkings=verbose>1);
            if verbose>0 println("            *** Computer guess $go = \"$guess\" ***"); end
        end
        if interactive
            print("Please provide guess: ")
            guess = readline();
        end
        output = simulatewordle(guess,answer);
        push!(outputall,output);
        if verbose>0 || interactive println(reduce(*,string.(output))); end
        wordlist = filterwordlist(wordlist,guess,output);
    end
    if verbose>0 println("🎉🍾🎊 DONE IN $go goes! 👏"); end
    if verbose>0 print(reduce(*,[reduce(*,string.(s))*"\n" for s in outputall])); end
    return go
end

function filterwordlist(wordlist::WordList,guess::String,output::Vector{Output})::WordList
    yellowcounts = Accumulator{Char,Int}();
    greyletters = Set{Char}();
    for (i,(letter,out)) in enumerate(zip(guess,output))
        if     out==🟨 inc!(yellowcounts,letter);
                       wordlist = [w for w in wordlist if w[i]!==letter]; # specifically not green
        elseif out==⬜ push!(greyletters,letter);
        elseif out==🟩 wordlist = [w for w in wordlist if w[i]==letter];
        else error("Unknown output: $output");
        end
    end
    nongreenind = findall(output.!=🟩);
    for letter in greyletters # then we know the actual count matches that of the number of yellows for the letter
        wordlist = [w for w in wordlist if sum(w[i]==letter for i in nongreenind)==yellowcounts[letter]];
    end
    for (letter,count) in yellowcounts
        wordlist = [w for w in wordlist if sum(w[i]==letter for i in nongreenind)≥count];
    end
    return wordlist
end

@memoize Dict function nextguess(algo::ExpectedHits,words::WordList;printworkings::Bool=false)::String
    if length(words)==1
        if printworkings println("only one word left: \"$(words[1])\""); end
        return words[1]
    end
    greenmatches = [all(w[i]==words[1][i] for w in words) for i in 1:WORD_LENGTH];
    letterfreqtables = Vector{DataFrame}();
    letterfreq = Vector{Accumulator}();
    for i = 1:WORD_LENGTH
        acc = Accumulator{Char,Int}();
        for w in words
            inc!(acc,w[i]);
        end
        push!(letterfreq,acc);
        push!(letterfreqtables,sort(DataFrame(letter=collect(keys(acc)),freq=collect(values(acc))),:freq,rev=true));
        if printworkings println("Position $i most frequent letters: "*join(["$l = $s" for (l,s) in zip(first(letterfreqtables[i],5).letter,first(letterfreqtables[i],5).freq)],", ")); end
    end
    wordscores = DataFrame(word=words,wordfreq=length(words):-1:1);
    wordscores.score .= 0;
    nongreenpositions = findall(.!greenmatches);
    explorationover = all(maximum(values(letterfreq[i]))==minimum(values(letterfreq[i])) for i = 1:WORD_LENGTH);
    for i = 1:nrow(wordscores)
        wordscores.score[i] = sum(letterfreq[j][wordscores.word[i][j]] for j in nongreenpositions) + 
        floor(mean(letterfreq[j][wordscores.word[i][k]] for j in nongreenpositions for k in nongreenpositions));
        if !explorationover
            wordscores.score[i] *= length(unique(wordscores.word[i])); # basic heuristic to penalise dublicate letters
        end
    end
    wordscores = sort(wordscores,[:score,:wordfreq],rev=true);
    if printworkings println("Next guess candidates:"); end
    if printworkings println(join(["$w (score=$s)" for (w,s) in zip(first(wordscores,5).word,first(wordscores,5).score)],", ")); end
    return wordscores.word[1]
end

@memoize Dict function nextguess(algo::EntropyMax,words::WordList;printworkings::Bool=false)::String
    allacc = Dict{String,Accumulator{Vector{Output}, Int64}}();
    for guess in words
        allacc[guess] = Accumulator{Vector{Output},Int}();
        for answer in words
            inc!(allacc[guess],simulatewordle(guess,answer));
        end
    end

    function entropy(acc)
        p = collect(values(acc))./sum(values(acc))
        return -sum(p.*log.(p))
    end

    entropies = Dict(w=>entropy(allacc[w]) for w in keys(allacc));
    entropiesdf = DataFrame(guess=collect(keys(entropies)),entropy=collect(values(entropies)));
    popularitydf = DataFrame(guess=words,popularity=reverse(1:length(words))); # tie-breaker
    entropiesdf = innerjoin(entropiesdf,popularitydf,on = :guess);
    entropiesdf = sort(entropiesdf,[:entropy,:popularity],rev=true);
    guess = entropiesdf.guess[1];
    if printworkings
        println("Guess with highest entropy of distribution of answers across puzzle outputs is \"$guess\":");
    end
    return guess
end

@memoize Dict function nextguess(algo::MiniMax,words::WordList;printworkings::Bool=false)::String
    allacc = Dict{String,Accumulator{Vector{Output}, Int64}}();
    for guess in words
        allacc[guess] = Accumulator{Vector{Output},Int}();
        for answer in words
            inc!(allacc[guess],simulatewordle(guess,answer));
        end
    end

    maxgrpsize = Dict(w=>maximum(values(v)) for (w,v) in allacc);
    maxgrpsizedf = DataFrame(guess=collect(keys(maxgrpsize)),maxgroupsize=collect(values(maxgrpsize)));
    popularitydf = DataFrame(guess=words,popularity=1:length(words)); # tie-breaker
    maxgrpsizedf = innerjoin(maxgrpsizedf,popularitydf,on = :guess);
    maxgrpsizedf = sort(maxgrpsizedf,[:maxgroupsize,:popularity]);
    guess = maxgrpsizedf.guess[1];
    if printworkings
        println("Guess with the smallest largest group size of distribution of answers \
        across puzzle outputs is \"$guess\", with largest group size = $(maxgrpsizedf.maxgroupsize[1])");
        for (output,count) in allacc[guess]
            println("$(reduce(*,string.(output))) => $count");
        end
    end
    return guess
end

function nextguess(algo::MostPopular,words::WordList;printworkings::Bool=false)::String
    if printworkings println("most popular word is: \"$(words[1])\""); end
    return words[1] # relies on popularity-ordering of the WordList
end

function simulatewordle(guessword::String,answer::String)::Vector{Output}
    @assert length(guessword)==WORD_LENGTH && length(answer)==WORD_LENGTH;
    out = fill(🟨,WORD_LENGTH);
    for i = 1:WORD_LENGTH
        if guessword[i]==answer[i]
            out[i] = 🟩;
        elseif !(guessword[i] in answer)
            out[i] = ⬜;
        end
    end
    # Now for corner-cases from guesses with multiple of a single correct letter
    nongreenlettersinanswer = Accumulator{Char,Int}();
    for l in collect(answer)[out.!=🟩] inc!(nongreenlettersinanswer,l); end
    for i in findall(out.==🟨)
        l = guessword[i];
        if nongreenlettersinanswer[l]>0
            dec!(nongreenlettersinanswer,l);
        else
            out[i] = ⬜;
        end
    end
    return out
end

@memoize function getwordlist()::WordList
    # from PG https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists#English
    words = WordList();
    for docid = 1:4
        for line in readlines("../data/WikitionaryPG$docid.txt")
            m = match(r"\[\[.*\]\]",line);
            if !isnothing(m)
                word = m.match[3:end-2];
                if length(word)==WORD_LENGTH push!(words,word); end
            end
        end
    end
    return intersect(words,readlines("../data/engwordlist.txt")) # list of english words from http://www.mieliestronk.com/corncob_lowercase.txt
end

if abspath(PROGRAM_FILE) == @__FILE__
    args = string.(ARGS);
    if any(contains(s,"answer=") for s in args)
        s = args[findfirst(contains(s,"answer=") for s in args)];
        answer = s[8:end];
    else
        words = getwordlist();
        answer = sample(words, Weights(reverse(1:length(words)))); # sample more frequent words more
    end
    playwordle(answer,interactive=("interactive" in args),withhelp=("help" in args));
end