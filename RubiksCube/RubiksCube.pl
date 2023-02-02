/* 
~~~~~~~~~~~~~~~ Prolog Mini Project: Solving a 2x2x2 Rubik's Cube ~~~~~~~~~~~~~~~
  				
	by Julian Kartte

	The goal of this project is to randomize and solve a 2x2x2 Rubik's Cube with Prolog.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~	Overview of the cube...	~~~~~~~~~~~~~~~~~~~~~~~~~~~
 	...in elements:				...in colors:
  	      U1 U2						  Y1 Y2
  	      U3 U4						  Y3 Y4
  	L1 L2 F1 F2 R1 R2 B1 B2		B1 B2 R1 R2 G1 G2 O1 O2
  	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
  	      D1 D2						  W1 W2
  	      D3 D4						  W3 W4
  
 	...with:
  	U: upper side				Y: yellow
 	F: front side				R: red
 	L: left side				B: blue
  	D: bottom down side			W: white
 	R: right side				G: green
  	B: back side				O: orange
  
~~~~~~~~~~~~~~~~~~~~~~~~~~~~	Movements: 	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Implemented moves are:
  		Up side left 	-> u_left
  		Up side right   -> u_right
  		Left side up 	-> l_up			
  		Left side down  -> l_down
  		Front side left	-> f_left
  		Front side right-> f_right
*/

/*
~~~~~~~~~~~~~~~ Executable rules: ~~~~~~~~~~~~~~~
	rand_cube(Steps, MovesList, OutputCube).
	-> 	Uses multiple moves to twist the cube and returne a puzzled cube
	 	@param Steps: 			number of moves used to twist the cube
	 	@param MovesList: 		list of moves used to twist the cube
	 	@param OutputCube: 		twisted cube
	>> 	Example: 		?- rand_cube(3, MovesList, OutputCube).
						MovesList = [u_left,l_down,f_left],
						OutputCube = cube(o,y,o,g,r,r,r,w,b,y,b,b,w,o,g,g,g,r,y,y,b,w,o,w).

	solver_init(C, E, ML).
	-> 	Solves a twisted cube
	 	@param C:	 			twisted cube
	 	@param E: 				finisehd cube
	 	@param ML:			 	list of moves used to solve the cube
	>> 	Example: 		?- solver_init(C, E, ML), input_ldul(C), finished(E).
						C = cube(o,o,y,y,r,w,r,w,y,r,b,b,o,w,g,g,g,g,y,r,b,b,o,w),
 						E = cube(y,y,y,y,w,w,w,w,b,b,b,b,g,g,g,g,r,r,r,r,o,o,o,o),
 						ML = [u_right,l_up] .
	>>	Example: 		?- solver_init(cube(y,o,r,w, y,r,o,w, o,y,b,g, r,w,b,g, b,g,r,w, b,g,o,y), E, ML), finished(E).
						C = cube(o,o,y,y,r,w,r,w,y,r,b,b,o,w,g,g,g,g,y,r,b,b,o,w),
 						E = cube(y,y,y,y,w,w,w,w,b,b,b,b,g,g,g,g,r,r,r,r,o,o,o,o),
 						ML = [u_left,f_right,f_right,l_down] .

	pipeline(Steps, PuzzlerCube, PuzzlerMoves, SolverCube, SolverMoves, ReverseSolverMoves).
	-> 	First randomizes a cube and then solves it
	 	@param Steps:	 			number of moves used to twist the cube
	 	@param PuzzlerCube: 		twisted cube
	 	@param PuzzlerMoves:	 	list of moves used to twist the cube
	 	@param SolverCube:	 		solved cube
	 	@param SolverMoves: 		list of moves used to solve the cube
	 	@param ReverseSolverMoves:	reverse list of moves used to solve the cube (only used for illustration purpose)
	>> 	Example: 		?- pipeline(3, PuzzlerCube, PuzzlerMoves, SolverCube, SolverMoves, ReverseSolverMoves).
						PuzzlerCube = cube(y,y,b,w,g,y,r,w,o,r,b,w,o,r,o,g,y,b,r,b,g,g,o,w),
						PuzzlerMoves = [l_down,u_right,f_right],
						SolverCube = cube(y,y,y,y,w,w,w,w,b,b,b,b,g,g,g,g,r,r,r,r,o,o,o,o),
						SolverMoves = [f_left,u_left,l_up],
						ReverseSolverMoves = [l_up,u_left,f_left] .

	step_by_step(InputCube, MoveList1, Finished1, MoveList2, Finished2, MoveList3, Finished3).
	-> 	Solves a cube in a certain way
	 	@param InputCube:	 		twisted cube
	 	@param MoveList1: 			moves used to get to solved stage 1
	 	@param Finished1:	 		cube of solved stage 1
	 	@param MoveList2: 			moves used to get to solved stage 2
	 	@param Finished2:	 		cube of solved stage 2
	 	@param MoveList3: 			moves used to get to solved stage 3
	 	@param Finished3:	 		cube of solved stage 3 (completely finished cibe)
	>> 	Example: 		?- step_by_step(cube(r,o,r,y, o,r,w,r, b,b,o,y, o,w,g,g, w,g,b,y, b,y,w,g),ML1,F1,ML2,F2,ML3,F3).
						cube(r,o,r,y,o,r,w,r,b,b,o,y,o,w,g,g,w,g,b,y,b,y,w,g)
						ML1 = [l_up,l_up],
						F1 = cube(o,o,w,y,r,r,r,r,y,o,b,b,o,w,g,g,g,g,y,y,b,b,w,w),
						ML2 = [l_down,u_left,l_up,u_right,f_left,l_up,f_right],
						F2 = cube(o,o,o,o,r,r,r,r,w,b,b,b,g,w,g,g,y,y,y,y,b,g,w,w),
						ML3 = [f_right,u_right,f_left,l_up,u_left,l_down,f_left,l_up,f_right,l_up,u_right,l_up,l_up],
						F3 = cube(o,o,o,o,r,r,r,r,b,b,b,b,g,g,g,g,y,y,y,y,w,w,w,w)
*/

/*~~~~~~~~~~~~~~~ Implemented example inputs (twisted cubes): ~~~~~~~~~~~~~~~ */
	input_ld(cube(o,y,o,y, r,w,r,w, b,b,b,b, g,g,g,g, y,r,y,r, o,w,o,w)).			% cube after l_down
	input_ul(cube(y,y,y,y, w,w,w,w, r,r,b,b, o,o,g,g, g,g,r,r, b,b,o,o)).			% cube after u_left
	input_fl(cube(y,y,g,g, b,b,w,w, b,y,b,y, w,g,w,g, r,r,r,r, o,o,o,o)).			% cube after f_left
	input_ur(cube(y,y,y,y, w,w,w,w, o,o,b,b, r,r,g,g, b,b,r,r, g,g,o,o)).			% cube after u_right
	input_lu(cube(r,y,r,y, o,w,o,w, b,b,b,b, g,g,g,g, w,r,w,r, o,y,o,y)).			% cube after l_up
	input_fr(cube(y,y,b,b, g,g,w,w, b,w,b,w, y,g,y,g, r,r,r,r, o,o,o,o)).			% cube after f_right
	input_ld2(cube(w,y,w,y, y,w,y,w, b,b,b,b, g,g,g,g, o,r,o,r, o,r,o,r)).			% cube after l_down, l_down
	input_ul2(cube(y,y,y,y, w,w,w,w, g,g,b,b, b,b,g,g, o,o,r,r, r,r,o,o)).			% cube after u_left, u_left
	input_fl2(cube(y,y,w,w, y,y,w,w, b,g,b,g, b,g,b,g, r,r,r,r, o,o,o,o)).			% cube after f_left, f_left
	input_ldul(cube(o,o,y,y, r,w,r,w, y,r,b,b, o,w,g,g, g,g,y,r, b,b,o,w)).			% cube after l_down, u_left
	input_test(cube(y,o,r,w, y,r,o,w, o,y,b,g, r,w,b,g, b,g,r,w, b,g,o,y)).			% cube after l_up, f_right, f_right, u_right
	input_testhard(cube(w,w,o,r, y,w,y,b, o,y,r,r, g,o,r,o, g,w,b,b, g,b,y,g)).
	input_testhard2(cube(y,r,g,y, b,b,r,w, b,w,g,w, o,b,r,r, o,g,o,y, w,o,g,y)).

/*~~~~~~~~~~~~~~~ Steps for solving the cube: ~~~~~~~~~~~~~~~ */
finishedstep1(cube(_,_,_,_, D,D,D,D, _,_,L,L, _,_,R,R, _,_,F,F, _,_,B,B)).		% solved down side and adjacent elements, stage 1
finishedstep2(cube(U,U,U,U, D,D,D,D, _,_,L,L, _,_,R,R, _,_,F,F, _,_,B,B)).		% additionally solved up side, stage 2
finished(cube(U,U,U,U, D,D,D,D, L,L,L,L, R,R,R,R, F,F,F,F, B,B,B,B)).			% finished cube in elements
finishedrand(cube(y,y,y,y, w,w,w,w, b,b,b,b, g,g,g,g, r,r,r,r, o,o,o,o)).		% finished cube in colors

/*~~~~~~~~~~~~~~~ Randomizer: ~~~~~~~~~~~~~~~ */
rand_cube(Steps, MovesList, OutputCube) :-
	set_prolog_flag(answer_write_options,[max_depth(0)]),
	random_select(M,[l_up,l_down,u_right,u_left,f_right,f_left],_),				% initialize list with first move, later used for comparison with previous move
	finishedrand(InputCube),
	move(M,InputCube,NextCube),
	Steps2 is Steps - 1,
	rand_cube(Steps2, [M], MovesList, OutputCube, NextCube).

rand_cube(0, MovesList, MovesList, OutputCube, OutputCube).
	
rand_cube(Steps, Moves, MovesList, OutputCube, InputCube) :-
	Steps > 0,
	last(Moves, H),
	random_select(M,[l_up,l_down,u_right,u_left,f_right,f_left],_),
	opposite_move(M, OpMove),
	H \= OpMove,
	move(M,InputCube,NextCube),
	append(Moves, [M], Moves2),
	Steps2 is Steps - 1,
	rand_cube(Steps2, Moves2, MovesList, OutputCube, NextCube).
	
rand_cube(Steps, Moves, MovesList, OutputCube, InputCube) :-
	Steps > 0,
	rand_cube(Steps, Moves, MovesList, OutputCube, InputCube).

/*~~~~~~~~~~~~~~~ Solver: ~~~~~~~~~~~~~~~ */

solver_init(C, E, ML) :- 			% C: input cube, E: finished cube, ML: list of moves
	set_prolog_flag(answer_write_options,[max_depth(0)]),
	solver(C, E, [], ML).

solver(C, C, ML, ML).
	
solver(C, E, T, ML) :- 
	append(T, [M], T1),
	solver(D,E,T1,ML),
	move(M,C,D).

/*~~~~~~~~~~~~~~~ Solve cube in separated steps: ~~~~~~~~~~~~~~~ */
step_by_step(InputCube, MoveList1, Finished1, MoveList2, Finished2, MoveList3, Finished3) :-
	writeln(InputCube),
	solver(InputCube, Finished1, _, MoveList1), finishedstep1(Finished1),
	solver(Finished1, Finished2, _, MoveList2), finishedstep2(Finished2),
	solver(Finished2, Finished3, _, MoveList3), finished(Finished3).
	
/*~~~~~~~~~~~~~~~ Randomizer and Solver combined: ~~~~~~~~~~~~~~ */
pipeline(Steps, PuzzlerCube, PuzzlerMoves, SolverCube, SolverMoves, ReverseSolverMoves) :-
	rand_cube(Steps, PuzzlerMoves, PuzzlerCube),
	solver_init(PuzzlerCube, SolverCube, SolverMoves),
	finished(SolverCube),
	reverse(SolverMoves, ReverseSolverMoves, []).

/*~~~~~~~~~~~~~~~ Helper Rules: ~~~~~~~~~~~~~~~ */
% get the reverse move
opposite_move(l_up, l_down).
opposite_move(l_down, l_up).
opposite_move(u_right, u_left).
opposite_move(u_left, u_right).
opposite_move(f_right, f_left).
opposite_move(f_left, f_right).

% reverse a list
reverse([],Z,Z).
reverse([H|T],Z,Acc) :- reverse(T,Z,[H|Acc]).

/*~~~~~~~~~~~~~~~ Implemented Movements: ~~~~~~~~~~~~~~~ */
% Movement LEFT up
move(
	l_up,					%					  PREVIOUS STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, U3, U4,		% 	      U1 U2						  Y1 Y2
		D1, D2, D3, D4,		% 	      U3 U4						  Y3 Y4
		L1, L2, L3, L4,		% 	L1 L2 F1 F2 R1 R2 B1 B2		B1 B2 R1 R2 G1 G2 O1 O2
		R1, R2, R3, R4,		% 	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		F1, F2, F3, F4,		% 	      D1 D2						  W1 W2
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		),					%					  NEXT STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		F1, U2, F3, U4,		% 	      F1 U2						  R1 Y2
		B4, D2, B2, D4,		% 	      F3 U4						  R3 Y4
		L2, L4, L1, L3,		% 	L2 L4 D1 F2 R1 R2 B1 U3		B2 B4 W1 R2 G1 G2 O1 Y3
		R1, R2, R3, R4,		% 	L1 L3 D3 F4 R3 R4 B3 U1		B1 B3 W3 R4 G3 G4 O3 Y1
		D1, F2, D3, F4,		% 	      B4 D2						  O4 W2
		B1, U3, B3, U1		% 	      B2 D4						  O2 W4
		)
	).

% Movement UP right
move(
	u_right,				%					  PREVIOUS STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, U3, U4,		% 	      U1 U2						  Y1 Y2
		D1, D2, D3, D4,		% 	      U3 U4						  Y3 Y4
		L1, L2, L3, L4,		%	L1 L2 F1 F2 R1 R2 B1 B2		B1 B2 R1 R2 G1 G2 O1 O2
		R1, R2, R3, R4,		%	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		F1, F2, F3, F4,		% 	      D1 D2						  W1 W2
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		),					%					  NEXT STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U2, U4, U1, U3,		% 	      U2 U4						  Y2 Y4
		D1, D2, D3, D4,		% 	      U1 U3						  Y1 Y3
		B1, B2, L3, L4,		% 	B1 B2 L1 L2 F1 F2 R1 R2		O1 O2 B1 B2 R1 R2 G1 G2
		F1, F2, R3, R4,		% 	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		L1, L2, F3, F4,		% 	      D1 D2						  W1 W2
		R1, R2, B3, B4		% 	      D3 D4						  W3 W4
		)
	).

% Movement FRONT right (clockwise)
move(
	f_right,				%					  PREVIOUS STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, U3, U4,		% 	      U1 U2						  Y1 Y2
		D1, D2, D3, D4,		% 	      U3 U4						  Y3 Y4
		L1, L2, L3, L4,		% 	L1 L2 F1 F2 R1 R2 B1 B2		B1 B2 R1 R2 G1 G2 O1 O2
		R1, R2, R3, R4,		% 	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		F1, F2, F3, F4,		% 	      D1 D2						  W1 W2
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		),					%					  NEXT STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, L4, L2,		% 	      U1 U2						  Y1 Y2
		R3, R1, D3, D4,		% 	      L4 L2						  B4 B2
		L1, D1, L3, D2,		% 	L1 D1 F3 F1 U3 R2 B1 B2		B1 W1 R3 R1 Y3 G2 O1 O2
		U3, R2, U4, R4,		% 	L3 D2 F4 F2 U4 R4 B3 B4		B3 W2 R4 R2 Y4 G4 O3 O4
		F3, F1, F4, F2,		% 	      R3 R1						  G3 G1
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		)
	).

% Movement UP left
move(
	u_left,					%					  PREVIOUS STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, U3, U4,		% 	      U1 U2						  Y1 Y2
		D1, D2, D3, D4,		% 	      U3 U4						  Y3 Y4
		L1, L2, L3, L4,		% 	L1 L2 F1 F2 R1 R2 B1 B2		B1 B2 R1 R2 G1 G2 O1 O2
		R1, R2, R3, R4,		% 	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		F1, F2, F3, F4,		% 	      D1 D2						  W1 W2
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		),					%					  NEXT STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U3, U1, U4, U2,		% 	      U3 U1						  Y3 Y1
		D1, D2, D3, D4,		% 	      U4 U2						  Y4 Y2
		F1, F2, L3, L4,		% 	F1 F2 R1 R2 B1 B2 L1 L2		R1 R2 G1 G2 O1 O2 B1 B2
		B1, B2, R3, R4,		% 	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		R1, R2, F3, F4,		% 	      D1 D2						  W1 W2
		L1, L2, B3, B4		% 	      D3 D4						  W3 W4
		)
	).

% Movement LEFT down
move(
	l_down,					%					  PREVIOUS STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, U3, U4,		% 	      U1 U2						  Y1 Y2
		D1, D2, D3, D4,		% 	      U3 U4						  Y3 Y4
		L1, L2, L3, L4,		% 	L1 L2 F1 F2 R1 R2 B1 B2		B1 B2 R1 R2 G1 G2 O1 O2
		R1, R2, R3, R4,		% 	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		F1, F2, F3, F4,		% 	      D1 D2						  W1 W2
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		),					%					  NEXT STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		B4, U2, B2, U4,		% 	      B4 U2						  O4 Y2
		F1, D2, F3, D4,		% 	      B2 U4						  O2 Y4
		L3, L1, L4, L2,		% 	L3 L1 U1 F2 R1 R2 B1 D3		B3 B1 R1 R2 G1 G2 O1 W3
		R1, R2, R3, R4,		% 	L4 L2 U3 F4 R3 R4 B3 D1		B4 B2 R3 R4 G3 G4 O3 W1
		U1, F2, U3, F4,		% 	      F1 D2						  R1 W2
		B1, D3, B3, D1		% 	      F3 D4						  R3 W4
		)
	).

% Movement FRONT left (counter clockwise)
move(
	f_left,					%					 PREVIOUS STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, U3, U4,		% 	      U1 U2						  Y1 Y2
		D1, D2, D3, D4,		% 	      U3 U4						  Y3 Y4
		L1, L2, L3, L4,		% 	L1 L2 F1 F2 R1 R2 B1 B2		B1 B2 R1 R2 G1 G2 O1 O2
		R1, R2, R3, R4,		% 	L3 L4 F3 F4 R3 R4 B3 B4		B3 B4 R3 R4 G3 G4 O3 O4
		F1, F2, F3, F4,		% 	      D1 D2						  W1 W2
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		),					%					  NEXT STATE
	cube(					% 		IN ELEMENTS:				IN COLORS:
		U1, U2, R1, R3,		% 	      U1 U2						  Y1 Y2
		L2, L4, D3, D4,		% 	      R1 R3						  G1 G3
		L1, U4, L3, U3,		% 	L1 U4 F2 F4 D2 R2 B1 B2		B1 Y4 R2 R4 W2 G2 O1 O2
		D2, R2, D1, R4,		% 	L3 U3 F1 F3 D1 R4 B3 B4		B3 Y3 R1 R3 W1 G4 O3 O4
		F2, F4, F1, F3,		% 	      L2 L4						  B2 B4
		B1, B2, B3, B4		% 	      D3 D4						  W3 W4
		)
	).