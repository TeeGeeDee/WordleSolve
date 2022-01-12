using Test

include("wordle.jl");

@test simulatewordle("stain","banal")==[⬜, ⬜, 🟨, ⬜, 🟨];
@test simulatewordle("among","banal")==[🟨, ⬜, ⬜, 🟨, ⬜];
@test simulatewordle("ranch","banal")==[⬜, 🟩, 🟩, ⬜, ⬜];
@test simulatewordle("panel","banal")==[⬜, 🟩, 🟩, ⬜, 🟩];
@test simulatewordle("banal","banal")==[🟩, 🟩, 🟩, 🟩, 🟩];

# undocumented (but sensible) behaviour regarding 🟨
@test simulatewordle("areas","crank")==[🟨, 🟩, ⬜, ⬜, ⬜];
@test simulatewordle("crack","crank")==[🟩, 🟩, 🟩, ⬜, 🟩];

for algo in [ExpectedHits(); EntropyMax(); MiniMax(); MostPopular()]
    @test playwordle("banal",withhelp=false,algo=algo,verbose=0)<=6;
    @test playwordle("tiger",withhelp=false,algo=algo,verbose=0)<=6;
    @test playwordle("slump",withhelp=false,algo=algo,verbose=0)<=6;
end
