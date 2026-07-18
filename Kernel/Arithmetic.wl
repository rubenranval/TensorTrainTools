(* ::Package:: *)

(* ::Subsection:: *)
(* Shared helpers *)


(* physical (tensor) dimensions of a core list *)
ttPhysDims[cores_List]:=Dimensions[#][[2]]&/@cores;

(* Check that all core lists represent tensors of the same dimensions.
   Returns the common dimension list, or $Failed after issuing head::shape. *)
ttSameDimsCheck[head_Symbol,cs_List]:=Module[{dims=ttPhysDims/@cs},
	If[SameQ@@dims,First[dims],
		Message[MessageName[head,"shape"],dims];$Failed]];


(* ::Subsection:: *)
(* Inner product *)


TensorTrainInnerProduct::shape="The tensor trains must represent tensors of the same dimensions, but have `1` and `2`.";

(* Sesquilinear inner product <a|b>, conjugate-linear in the FIRST argument. *)
TensorTrainInnerProduct[TensorTrain[ca_List],TensorTrain[cb_List]]:=Module[
	{n=Length[ca],dimsA=ttPhysDims[ca],dimsB=ttPhysDims[cb],env,a,b,aL,p,aR,bL,q,bR,t},
	If[dimsA=!=dimsB,Message[TensorTrainInnerProduct::shape,dimsA,dimsB];Return[$Failed]];
	env={{1}};(*(chiA,chiB), starts 1x1*)
	Do[
		a=ca[[k]];b=cb[[k]];
		{aL,p,aR}=Dimensions[a];
		{bL,q,bR}=Dimensions[b];
		t=env . ArrayReshape[b,{bL,q*bR}];(*absorb env into b: (aL, s*bR)*)
		t=ArrayReshape[t,{aL*p,bR}];(*regroup rows as (aL, s); p==q*)
		env=ConjugateTranspose[ArrayReshape[a,{aL*p,aR}]] . t,(*contract conj(a) over (aL, s)*)
		{k,1,n}];
	env[[1,1]]];


(* ::Subsection:: *)
(* Hadamard (elementwise) product *)


TensorTrainHadamard::shape="The tensor trains must all represent tensors of the same dimensions, but have `1`.";

TensorTrainHadamard[t_TensorTrain]:=t;

TensorTrainHadamard[tts__TensorTrain]:=Module[{cs=First/@{tts},dims,n,m,cores},
	dims=ttSameDimsCheck[TensorTrainHadamard,cs];
	If[dims===$Failed,Return[$Failed]];
	n=Length[dims];m=Length[cs];
	cores=Table[
		(*per physical slice s: Kronecker the (left x right) matrices of all
		  factors; Table puts s first, so transpose it back to (left, s, right)*)
		Transpose[
			Table[KroneckerProduct@@Table[cs[[i,j,All,s,All]],{i,m}],{s,dims[[j]]}],
			{2,1,3}],
		{j,n}];
	TensorTrain[cores]];


(* ::Subsection:: *)
(* Sum *)


TensorTrainPlus::shape="The tensor trains must all represent tensors of the same dimensions, but have `1`.";

TensorTrainPlus[t_TensorTrain]:=t;

TensorTrainPlus[tts__TensorTrain]:=Module[{cs=First/@{tts},dims,n,m,cores,blocks},
	dims=ttSameDimsCheck[TensorTrainPlus,cs];
	If[dims===$Failed,Return[$Failed]];
	n=Length[dims];m=Length[cs];
	(*a single core represents a vector; the sum is elementwise, no rank concept*)
	If[n==1,Return[TensorTrain[{Total[cs[[All,1]]]}]]];
	cores=Table[
		Transpose[
			(*build per physical slice, then reorder to (left, phys, right)*)
			Table[
				blocks=Table[cs[[i,j,All,s,All]],{i,m}];
				Which[
					j==1,ArrayFlatten[{blocks}],(*row: 1 x (r1+...+rm)*)
					j==n,ArrayFlatten[List/@blocks],(*column: (l1+...+lm) x 1*)
					True,ArrayFlatten[Table[If[r==c,blocks[[r]],0],{r,m},{c,m}]] (*block diagonal*)],
				{s,dims[[j]]}],
			{2,1,3}],
		{j,n}];
	TensorTrain[cores]];


(* ::Subsection:: *)
(* Scaling *)


TensorTrainScale[c_,TensorTrain[cores_List]]:=TensorTrain[MapAt[c #&,cores,1]];


(* ::Subsection:: *)
(* Lifting: accept raw core lists anywhere a TensorTrain is expected *)


(* Convert the leftmost List argument via the validating constructor and
   recurse; propagate $Failed (with the constructor's messages) on bad cores. *)
TensorTrainInnerProduct[pre___,c_List,post___]:=
	With[{t=TensorTrain[c]},If[t===$Failed,$Failed,TensorTrainInnerProduct[pre,t,post]]];
TensorTrainHadamard[pre___,c_List,post___]:=
	With[{t=TensorTrain[c]},If[t===$Failed,$Failed,TensorTrainHadamard[pre,t,post]]];
TensorTrainPlus[pre___,c_List,post___]:=
	With[{t=TensorTrain[c]},If[t===$Failed,$Failed,TensorTrainPlus[pre,t,post]]];
TensorTrainScale[c_,cores_List]:=
	With[{t=TensorTrain[cores]},If[t===$Failed,$Failed,TensorTrainScale[c,t]]];
