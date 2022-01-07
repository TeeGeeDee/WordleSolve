using DataStructures
using DataFrames
using Statistics
using StatsBase

@enum Output ⬜ 🟨 🟩;
const WORD_LENGTH = 5;

mutable struct GameState
    greenmatches ::Set{Tuple{Int,Char}}
    yellowmatches::Set{Tuple{Int,Char}}
    grayletters  ::Set{Char}
    words        ::Vector{String}
    GameState() = new(Set{Tuple{Int,Char}}(),Set{Tuple{Int,Char}}(),Set{Char}(),getwordsfreqorder());
end

function playwordle(answer::String;interactive::Bool=false,withhelp::Bool=false)::Int
    @assert length(answer)==WORD_LENGTH;
    @assert all(islowercase(c) for c in answer);
    println("LET'S PLAY WORDLE"* (interactive ? "" : " (ANSWER IS \"$answer\")")*"\n");
    gamestate = GameState();
    output,go = fill(⬜,WORD_LENGTH),0;
    outputall = Vector{Vector{Output}}();
    while !all(output.==🟩)
        go += 1;
        println("\n ****** Go $go: ******");
        if !interactive || withhelp
            guess = nextguess(gamestate);
            println("\n            *** Computer guess $go = \"$guess\" ***\n");
        end
        if interactive
            print("Please provide guess:")
            guess = readline();
        end
        output = simulatewordle(guess,answer);
        push!(outputall,output);
        println(reduce(*,string.(output)));
        updategame!(gamestate,guess,output);
    end
    println("🎉🍾🎊 DONE IN $go goes! 👏");
    print(reduce(*,[reduce(*,string.(s))*"\n" for s in outputall]));
    return go
end

function updategame!(gamestate::GameState,guess::String,output::Vector{Output})
    for (i,(letter,out)) in enumerate(zip(guess,output))
        if     out==⬜ push!(gamestate.grayletters,letter);
        elseif out==🟨 push!(gamestate.yellowmatches,(i,letter));
        elseif out==🟩 push!(gamestate.greenmatches,(i,letter));
        else error("Unknown output");
        end
    end
    for (position,letter) in gamestate.greenmatches
        gamestate.words = [w for w in gamestate.words if w[position]==letter];
    end
    for (position,letter) in gamestate.yellowmatches
        gamestate.words = [w for w in gamestate.words if (w[position]!=letter) && (letter in w)];
    end
    for letter in gamestate.grayletters
        gamestate.words = [w for w in gamestate.words if !(letter in w)];
    end
end

function nextguess(gamestate::GameState)::String
    letterfreqtables = Vector{DataFrame}();
    letterfreq = Vector{Accumulator}();
    for i = 1:WORD_LENGTH
        acc = Accumulator{Char,Int}();
        for w in gamestate.words
            inc!(acc,w[i]);
        end
        push!(letterfreq,acc);
        push!(letterfreqtables,sort(DataFrame(letter=collect(keys(acc)),freq=collect(values(acc))),:freq,rev=true));
        println("Position $i most frequent letters:");
        println(join(["$l = $s" for (l,s) in zip(first(letterfreqtables[i],5).letter,first(letterfreqtables[i],5).freq)],", "));
        println("");
    end
    wordscores = DataFrame(word=gamestate.words,wordfreq=length(gamestate.words):-1:1);
    wordscores.score .= 0;
    nongreenpositions = setdiff(1:WORD_LENGTH,[i for (i,c) in gamestate.greenmatches]);
    explorationover = all(maximum(values(letterfreq[i]))==minimum(values(letterfreq[i])) for i = 1:WORD_LENGTH);
    for i = 1:nrow(wordscores)
        wordscores.score[i] = sum(letterfreq[j][wordscores.word[i][j]] for j in nongreenpositions) + 
        floor(mean(letterfreq[j][wordscores.word[i][k]] for j in nongreenpositions for k in nongreenpositions));
        if !explorationover
            wordscores.score[i] *= length(unique(wordscores.word[i])); # basic heuristic to penalise dublicate letters
        end
    end
    wordscores = sort(wordscores,[:score,:wordfreq],rev=true);
    println("Next guess candidates:");
    println(join(["$w (score=$s)" for (w,s) in zip(first(wordscores,5).word,first(wordscores,5).score)],", "));
    return wordscores.word[1]
end

function simulatewordle(guessword::String,answer::String)::Vector{Output}
    @assert length(guessword)==WORD_LENGTH && length(answer)==WORD_LENGTH;
    out = fill(⬜,WORD_LENGTH);
    for i = 1:WORD_LENGTH
        if guessword[i]==answer[i]
            out[i] = 🟩;
        elseif guessword[i] in answer
            out[i] = 🟨;
        end
    end
    return out
end

function getwordsfreqorder()::Vector{String}
    # from PG https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists#English
    words = Vector{String}();
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
        words = getwordsfreqorder();
        answer = sample(words, Weights(reverse(1:length(words)))); # sample more frequent words more
    end
    playwordle(answer,interactive=("interactive" in args),withhelp=("help" in args));
end