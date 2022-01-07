# WordleSolve
Simple solver for the word game Worlde https://www.powerlanguage.co.uk/wordle/

## Run a solver for a given answer
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

## Play interactively
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

## Algorithm
The algorithm is heuristic-based, creating a score for each possible word guess.
Given a list of valid guesses (at the start this is all 5-letter words, later this is reduced by constraints of outputs of previous guesses), we can score
each word by
* For each letter (that isn't already 🟩), the frequency of the letter in the same position among valid words (proxy for "probability of getting 🟩")
* For each letter (that isn't already 🟩), the frequency of the letter in all non-🟩 positions (proxy for "probability of getting 🟨)
    * This is divided by the number of non-🟩 letters, since 🟨 is less useful than 🟩 (and less useful the more letters remaining)
* As long as we're early enough in the same that 🟨 are useful, multiply the sum of the above by the number of unique non-🟩 letters (since duplicate 🟨 are less useful)
* Finally, ties are broken by the word appearance frequency in Project Gutenberg books

## Ideas for improvement
* For every word pair we can calculate the game output. Then for every possible answer word we can calculate the number of words that correspond to each output, for every possible guess.
* We can choose a loss-function (e.g. minimax) and choose the best guess, averaging over all possible answers
* This is a big problem, so probably needs some mote-carlo or something
* The above is greedy, and sub-optimal. Can extend further using dynamic programming/RL
