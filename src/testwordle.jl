using Test

include("wordle.jl");

@test simulatewordle("stain","banal")==[⬜, ⬜, 🟨, ⬜, 🟨];
@test simulatewordle("among","banal")==[🟨, ⬜, ⬜, 🟨, ⬜];
@test simulatewordle("ranch","banal")==[⬜, 🟩, 🟩, ⬜, ⬜];
@test simulatewordle("panel","banal")==[⬜, 🟩, 🟩, ⬜, 🟩];
@test simulatewordle("banal","banal")==[🟩, 🟩, 🟩, 🟩, 🟩];

@test playwordle("banal",withhelp=false)<=6;
@test playwordle("tiger",withhelp=false)<=6;
@test playwordle("slump",withhelp=false)<=6;
