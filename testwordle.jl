using Test

include("wordle.jl");

@test simulatewordle("stain","banal")==[Gray, Gray, Yellow, Gray, Yellow];
@test simulatewordle("among","banal")==[Yellow, Gray, Gray, Yellow, Gray];
@test simulatewordle("ranch","banal")==[Gray, Green, Green, Gray, Gray];
@test simulatewordle("panel","banal")==[Gray, Green, Green, Gray, Green];
@test simulatewordle("banal","banal")==[Green, Green, Green, Green, Green];

@test playwordle("banal")==3;