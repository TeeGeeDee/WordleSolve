using DataStructures
using DataFrames

@enum Output Gray Yellow Green;
const WORD_LENGTH = 5;

mutable struct GameState
    greenmatches ::Set{Tuple{Int,Char}}
    yellowmatches::Set{Tuple{Int,Char}}
    grayletters  ::Set{Char}
    words        ::Vector{String}
    GameState(words) = new(Set{Tuple{Int,Char}}(),Set{Tuple{Int,Char}}(),Set{Char}(),words);
end

function playwordle(answer::String)::Int
    @assert length(answer)==WORD_LENGTH;
    println("LET'S PLAY WORDLE (ANSWER IS \"$answer\")\n");
    wordsall = readlines("engwordlist.txt"); # list of english words from http://www.mieliestronk.com/corncob_lowercase.txt
    wordsall = [w for w in wordsall if length(w)==WORD_LENGTH];
    gamestate = GameState(wordsall);
    output,go = fill(Gray,WORD_LENGTH),0;
    while !all(output.==Green)
        go += 1;
        println("\n ****** Go $go: ******");
        guess = nextguess(gamestate);
        println("\n        *** Guess = \"$guess\" ***\n");
        output = simulatewordle(guess,answer);
        println("        *** $output ***");
        updategame!(gamestate,guess,output);
    end
    return go
end

function updategame!(gamestate::GameState,guess::String,output::Vector{Output})
    for (i,(letter,out)) in enumerate(zip(guess,output))
        if     out==Gray   push!(gamestate.grayletters,letter);
        elseif out==Yellow push!(gamestate.yellowmatches,(i,letter));
        elseif out==Green  push!(gamestate.greenmatches,(i,letter));
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

function nextguess(gamestate)
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
        println(Dict(zip(first(letterfreqtables[i],5).letter,first(letterfreqtables[i],5).freq)));
        println("");
    end
    wordscores = DataFrame(word=gamestate.words);
    wordscores.score .= 0;
    for i = 1:nrow(wordscores)
        wordscores.score[i] = sum(letterfreq[j][wordscores.word[i][j]] for j in 1:WORD_LENGTH);
        wordscores.score[i] *= length(unique(wordscores.word[i])); # basic heuristic to penalise dublicate letters
    end
    wordscores = sort(wordscores,:score,rev=true);
    println("Next guess candidates:");
    println(Dict(zip(first(wordscores,5).word,first(wordscores,5).score)));
    return wordscores.word[1];
end

function simulatewordle(guessword::String,answer::String)::Vector{Output}
    @assert length(guessword)==WORD_LENGTH && length(answer)==WORD_LENGTH;
    out = fill(Gray,WORD_LENGTH);
    for i = 1:WORD_LENGTH
        if guessword[i]==answer[i]
            out[i] = Green;
        elseif guessword[i] in answer
            out[i] = Yellow;
        end
    end
    return out
end
