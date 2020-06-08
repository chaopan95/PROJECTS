clear all;
clc;
load('exampleIOPA5.mat');

%{
V = exampleINPUT.t6a1;
G = exampleINPUT.t6a2;
F = exampleINPUT.t6a3;
A = exampleINPUT.t6a4;
LogBS = BlockLogDistribution(V, G, F, A);
%}

%{
A = exampleINPUT.t7a1{1};
G = exampleINPUT.t7a2{1};
F = exampleINPUT.t7a3{1};
A = GibbsTrans(A, G, F);
%}

%{
G = exampleINPUT.t8a1{1};
F = exampleINPUT.t8a2{1};
E = exampleINPUT.t8a3{1};
TransName = exampleINPUT.t8a4{1};
mix_time = exampleINPUT.t8a5{1};
num_samples = exampleINPUT.t8a6{1};
sampling_interval = exampleINPUT.t8a7{1};
A0 = exampleINPUT.t8a8{1};
[M, all_samples] = MCMCInference(...
    G, F, E, TransName, mix_time, num_samples, sampling_interval, A0);
%}

%{
A = exampleINPUT.t9a1{1};
G = exampleINPUT.t9a2{1};
F = exampleINPUT.t9a3{1};
A = MHUniformTrans(A, G, F);
%}

%
A = exampleINPUT.t10a1{1};
G = exampleINPUT.t10a2{1};
F = exampleINPUT.t10a3{1};
variant = exampleINPUT.t10a4{1};
A = MHSWTrans(A, G, F, variant);
%

