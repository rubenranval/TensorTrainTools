(* ::Package:: *)

(* les dimensions des differents coeurs *)
ttPhysDims[cores_List]:=Dimensions[#][[2]]&/@cores;
(* toutes les listes de coeurs doivent avoir la meme dimension! *)
ttSameDimsCheck[head_Symbol,cs_List]:=Module[{dims=ttPhysDims/@cs},
	If[SameQ@@dims,First[dims],
		Message[MessageName[head,"shape"],dims];$Failed]];


(* ::Subsection:: *)
(* Inner product *)


TensorTrainInnerProduct::shape="The tensor trains must represent tensors of the same dimensions, but have `1` and `2`.";

TensorTrainInnerProduct[TensorTrain[ca_List],TensorTrain[cb_List]]:=Module[
	{n=Length[ca],dimsA=ttPhysDims[ca],dimsB=ttPhysDims[cb],env,a,b,aL,p,aR,bL,q,bR,t},
	If[dimsA=!=dimsB,Message[TensorTrainInnerProduct::shape,dimsA,dimsB];Return[$Failed]];
	env={{1}};
	Do[
		a=ca[[k]];b=cb[[k]];
		{aL,p,aR}=Dimensions[a];
		{bL,q,bR}=Dimensions[b];
		t=env . ArrayReshape[b,{bL,q*bR}];
		t=ArrayReshape[t,{aL*p,bR}];
		env=ConjugateTranspose[ArrayReshape[a,{aL*p,aR}]] . t,
		{k,1,n}];
	env[[1,1]]];


(* ::Subsection:: *)
(* Hadamard *)


TensorTrainHadamard::shape="The tensor trains must all represent tensors of the same dimensions, but have `1`.";

TensorTrainHadamard[t_TensorTrain]:=t;
TensorTrainHadamard[tts__TensorTrain]:=Module[{cs=First/@{tts},dims,n,m,cores},
	dims=ttSameDimsCheck[TensorTrainHadamard,cs];
	If[dims===$Failed,Return[$Failed]];
	n=Length[dims];m=Length[cs];
	cores=Table[
		Transpose[
			Table[KroneckerProduct@@Table[cs[[i,j,All,s,All]],{i,m}],{s,dims[[j]]}],
			{2,1,3}],
		{j,n}];
	TensorTrain[cores]];


(* ::Subsection:: *)
(* Plus *)


TensorTrainPlus::shape="The tensor trains must all represent tensors of the same dimensions, but have `1`.";

TensorTrainPlus[t_TensorTrain]:=t;

TensorTrainPlus[tts__TensorTrain]:=Module[{cs=First/@{tts},dims,n,m,cores,blocks},
	dims=ttSameDimsCheck[TensorTrainPlus,cs];
	If[dims===$Failed,Return[$Failed]];
	n=Length[dims];m=Length[cs];
	If[n==1,Return[TensorTrain[{Total[cs[[All,1]]]}]]];
	cores=Table[
		Transpose[
			Table[
				blocks=Table[cs[[i,j,All,s,All]],{i,m}];
				Which[
					j==1,ArrayFlatten[{blocks}],
					j==n,ArrayFlatten[List/@blocks],
					True,ArrayFlatten[Table[If[r==c,blocks[[r]],0],{r,m},{c,m}]]],
				{s,dims[[j]]}],
			{2,1,3}],
		{j,n}];
	TensorTrain[cores]];


(* ::Subsection:: *)
(* Scale *)


TensorTrainScale[c_,TensorTrain[cores_List]]:=TensorTrain[MapAt[c #&,cores,1]];


(* verifications pour passer des listes de coeurs aux tensor trains *)
TensorTrainInnerProduct[pre___,c_List,post___]:=
	With[{t=TensorTrain[c]},If[t===$Failed,$Failed,TensorTrainInnerProduct[pre,t,post]]];
TensorTrainHadamard[pre___,c_List,post___]:=
	With[{t=TensorTrain[c]},If[t===$Failed,$Failed,TensorTrainHadamard[pre,t,post]]];
TensorTrainPlus[pre___,c_List,post___]:=
	With[{t=TensorTrain[c]},If[t===$Failed,$Failed,TensorTrainPlus[pre,t,post]]];
TensorTrainScale[c_,cores_List]:=
	With[{t=TensorTrain[cores]},If[t===$Failed,$Failed,TensorTrainScale[c,t]]];
