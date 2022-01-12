# WordleSolve
Solvers for the word game Worlde https://www.powerlanguage.co.uk/wordle/

## Algorithms

There are 4 greedy algorithms:
* Word popularity (simple baseline)
* Maximization of expectation of number of 🟩, plus number of 🟨 (deflated by their lesser worth)
* Maximization of the entropy of the distribution of all anwsers to all outputs - we want an even distribution
* Minimize the maximum number of possible answers that get mapped to the same output

# Word popularity

Simple baseline algorithm:
* Restrict the word list to reconcile with all observed guess-output combinations
* Guess the most frequently appearing word in Project Gutenberg books

# 🟩 Exectation Maximization (letter frequency method)

The algorithm is heuristic-based, creating a score for each possible word guess.
Given a list of valid guesses (at the start this is all 5-letter words, later this is reduced by constraints of outputs of previous guesses), we can score
each word by
* For each letter (that isn't already 🟩), the frequency of the letter in the same position among valid words (proxy for "probability of getting 🟩")
* For each letter (that isn't already 🟩), the frequency of the letter in all non-🟩 positions (proxy for "probability of getting 🟨)
    * This is divided by the number of non-🟩 letters, since 🟨 is less useful than 🟩 (and less useful the more letters remaining)
* As long as we're early enough in the same that 🟨 are useful, multiply the sum of the above by the number of unique non-🟩 letters (since duplicate 🟨 are less useful)
* Finally, ties are broken by the word appearance frequency in Project Gutenberg books

# Entropy maximization

Any guess is a map from all posible words to all possible (3^5=243) outputs. We wish the split to be as even as possible so that the output convays maximal information.
We simply iterate this after filtering the word list to comply with all seen guess-output combinations.

# MiniMax

Similar to above we calculate the mapping to all possible outputs, but this time we just minimize the size of the largest group. This is trying to control the worst-case scenario.

# Interface
## Run a solver for a given answer

## 🟩 Exectation Maximization (letter frequency method)
Sample output of: `julia wordle.jl answer=final`

LET'S PLAY WORDLE (ANSWER IS "final")

 ****** Go 1 ****** \
Position 1 most frequent letters: s = 405, c = 223, b = 215, t = 189, p = 180\
Position 2 most frequent letters: a = 411, o = 393, e = 312, i = 284, r = 284\
Position 3 most frequent letters: a = 360, i = 281, o = 274, r = 226, e = 219\
Position 4 most frequent letters: e = 489, n = 210, r = 188, a = 182, l = 181\
Position 5 most frequent letters: s = 447, e = 446, y = 325, t = 255, r = 199\
Next guess candidates:\
cares (score=10065), cores (score=9915), canes (score=9835), cones (score=9685), pores (score=9685)

*** Computer guess 1 = "cares" ***
            
⬜🟨⬜⬜⬜


 ****** Go 2 ******
 
Position 1 most frequent letters: a = 51, t = 11, p = 11, f = 6, g = 6\
Position 2 most frequent letters: l = 30, o = 22, i = 12, u = 12, m = 6\
Position 3 most frequent letters: a = 35, o = 17, l = 10, i = 9, n = 8\
Position 4 most frequent letters: a = 29, i = 19, n = 16, o = 10, l = 10\
Position 5 most frequent letters: a = 21, l = 20, t = 19, y = 12, n = 11\
Next guess candidates:\
aloft (score=660), along (score=655), plait (score=630), aloud (score=620), plant (score=615)

*** Computer guess 2 = "aloft" *** \
🟨🟨⬜🟨⬜

 ****** Go 3 ******
 
Position 1 most frequent letters: f = 2\
Position 2 most frequent letters: i = 1, u = 1\
Position 3 most frequent letters: n = 1, g = 1\
Position 4 most frequent letters: a = 2\
Position 5 most frequent letters: l = 2\
Next guess candidates:\
final (score=8), fugal (score=8)

*** Computer guess 3 = "final" *** \
🟩🟩🟩🟩🟩\
🎉🍾🎊 DONE IN 3 goes! 👏\
⬜🟨⬜⬜⬜\
🟨🟨⬜🟨⬜\
🟩🟩🟩🟩🟩

## Word popularity algo

playwordle("taken",algo=MostPopular(),verbose=2) \
LET'S PLAY WORDLE (ANSWER IS "taken")

 ****** Go 1 ****** \
most popular word is: "which" \
            *** Computer guess 1 = "which" *** \
⬜⬜⬜⬜⬜

 ****** Go 2 ****** \
most popular word is: "about" \
            *** Computer guess 2 = "about" *** \
🟨⬜⬜⬜🟨

 ****** Go 3 ****** \
most popular word is: "taken" \
            *** Computer guess 3 = "taken" *** \
🟩🟩🟩🟩🟩 \
🎉🍾🎊 DONE IN 3 goes! 👏 \
⬜⬜⬜⬜⬜ \
🟨⬜⬜⬜🟨 \
🟩🟩🟩🟩🟩

## Entropy maximizaiton algo

playwordle("taken",algo=EntropyMax(),verbose=2) \
LET'S PLAY WORDLE (ANSWER IS "taken")

 ****** Go 1 ****** \
Guess with highest entropy of distribution of answers across puzzle outputs is "tears": \
🟩🟩🟩⬜⬜ => 1 \
⬜🟩🟩🟩⬜ => 7 \
⬜⬜🟨🟨⬜ => 64 \
🟨⬜🟨⬜🟨 => 14 \
⬜🟨🟩🟨🟨 => 1 \
🟨⬜🟨⬜⬜ => 51 \
⬜🟩⬜🟨⬜ => 32 \
⬜🟨🟩⬜🟨 => 18 \
⬜🟨⬜🟨⬜ => 134 \
🟨🟩🟩🟨⬜ => 1 \
🟩🟨🟨⬜⬜ => 5 \
... \
⬜🟩🟩⬜⬜ => 13 \
⬜🟩⬜⬜🟩 => 19 \
⬜🟨⬜🟩🟨 => 6 \
🟩⬜⬜⬜🟩 => 6 \
🟩⬜🟨⬜⬜ => 18 \
⬜🟩⬜⬜🟨 => 15 \
            *** Computer guess 1 = "tears" *** \
🟩🟨🟨⬜⬜

 ****** Go 2 ****** \
Guess with highest entropy of distribution of answers across puzzle outputs is "taken": \
🟩🟨🟨🟨⬜ => 1 \
🟩🟩🟩🟩🟩 => 1 \
🟩🟩⬜🟨⬜ => 1 \
🟩🟨⬜🟨⬜ => 1 \
🟩🟩⬜🟩⬜ => 1 \
            *** Computer guess 2 = "taken" *** \
🟩🟩🟩🟩🟩 \
🎉🍾🎊 DONE IN 2 goes! 👏 \
🟩🟨🟨⬜⬜ \
🟩🟩🟩🟩🟩

## MiniMax

playwordle("taken",algo=MiniMax(),verbose=2) \
LET'S PLAY WORDLE (ANSWER IS "taken")

 ****** Go 1 ****** \
Guess with the smallest largest group size of distribution of answers across puzzle outputs is "raise", with largest group size = 156 \
            *** Computer guess 1 = "raise" *** \
⬜🟩⬜⬜🟨

 ****** Go 2 ****** \
Guess with the smallest largest group size of distribution of answers across puzzle outputs is "cadet", with largest group size = 9 \
            *** Computer guess 2 = "cadet" *** \
⬜🟩⬜🟩🟨

 ****** Go 3 ****** \
Guess with the smallest largest group size of distribution of answers across puzzle outputs is "taken", with largest group size = 1 \
            *** Computer guess 3 = "taken" *** \
🟩🟩🟩🟩🟩 \
🎉🍾🎊 DONE IN 3 goes! 👏 \
⬜🟩⬜⬜🟨 \
⬜🟩⬜🟩🟨 \
🟩🟩🟩🟩🟩


## Play manually, interactively
Sample output of: `julia wordle.jl interactive answer=slump` (if answer not provided, it's chosen at random, weighed by frequency of appearance in books)

LET'S PLAY WORDLE

 ****** Go 1: ****** \
Please provide guess: teams\
⬜⬜⬜🟩🟨

 ****** Go 2: ****** \
Please provide guess: slimy\
🟩🟩⬜🟩⬜

 ****** Go 3: ****** \
Please provide guess: slump\
🟩🟩🟩🟩🟩

🎉🍾🎊 DONE IN 3 goes! 👏

⬜⬜⬜🟩🟨\
🟩🟩⬜🟩⬜\
🟩🟩🟩🟩🟩

# Ideas for improvement
* For every word pair we can calculate the game output. Then for every possible answer word we can calculate the number of words that correspond to each output, for every possible guess.
* We can choose a loss-function (e.g. minimax) and choose the best guess, averaging over all possible answers
* This is a big problem, so probably needs some mote-carlo or something
* The above is greedy, and sub-optimal. Can extend further using dynamic programming/RL
