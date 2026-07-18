(* ::Package:: *)

TensorTrainInnerProduct::shape="The tensor trains must represent tensors of the same dimensions, but have `1` and `2`.";

TensorTrainInnerProduct[TensorTrain[ca_List],TensorTrain[cb_List]]:=Module[{n=Length[ca],dimsA,dimsB,env,a,b,aL,p,aR,bL,q,bR,t},dimsA=Dimensions[#][[2]]&/@ca;
dimsB=Dimensions[#][[2]]&/@cb;
If[Length[ca]=!=Length[cb]||dimsA=!=dimsB,Message[TensorTrainInnerProduct::shape,dimsA,dimsB];Return[$Failed]];
env={{1}};(*(chiA,chiB),starts 1x1*)Do[a=ca[[k]];b=cb[[k]];
{aL,p,aR}=Dimensions[a];
{bL,q,bR}=Dimensions[b];
t=env . ArrayReshape[b,{bL,q*bR}];(*absorb env into b:(aL,s*bR)*)t=ArrayReshape[t,{aL*p,bR}];(*regroup rows as (aL,s);p==q*)env=ConjugateTranspose[ArrayReshape[a,{aL*p,aR}]] . t,(*contract conj(a) over (aL,s)*){k,1,n}];
env[[1,1]]];

TensorTrainInnerProduct[a_List,b_]:=With[{ta=TensorTrain[a]},If[ta===$Failed,$Failed,TensorTrainInnerProduct[ta,b]]];
TensorTrainInnerProduct[a_TensorTrain,b_List]:=With[{tb=TensorTrain[b]},If[tb===$Failed,$Failed,TensorTrainInnerProduct[a,tb]]];


TensorTrainHadamard::shape="The tensor trains must represent tensors of the same dimensions, but have `1` and `2`.";

TensorTrainHadamard[TensorTrain[ca_List],TensorTrain[cb_List]]:=Module[{n=Length[ca],dimsA,dimsB,cores},dimsA=Dimensions[#][[2]]&/@ca;
dimsB=Dimensions[#][[2]]&/@cb;
If[Length[ca]=!=Length[cb]||dimsA=!=dimsB,Message[TensorTrainHadamard::shape,dimsA,dimsB];Return[$Failed]];
cores=Table[With[{a=ca[[k]],b=cb[[k]],nk=dimsA[[k]]},(*per physical slice s:Kronecker the (left x right) matrices;
Table puts s first,so transpose it back to the middle (left,s,right)*)Transpose[Table[KroneckerProduct[a[[All,s,All]],b[[All,s,All]]],{s,nk}],{2,1,3}]],{k,n}];
TensorTrain[cores]];

TensorTrainHadamard[a_List,b_]:=With[{ta=TensorTrain[a]},If[ta===$Failed,$Failed,TensorTrainHadamard[ta,b]]];
TensorTrainHadamard[a_TensorTrain,b_List]:=With[{tb=TensorTrain[b]},If[tb===$Failed,$Failed,TensorTrainHadamard[a,tb]]];


TensorTrainPlus::shape="The tensor trains must represent tensors of the same dimensions, but have `1` and `2`.";

TensorTrainPlus[TensorTrain[ca_List],TensorTrain[cb_List]]:=Module[{n=Length[ca],dimsA,dimsB,cores},dimsA=Dimensions[#][[2]]&/@ca;
dimsB=Dimensions[#][[2]]&/@cb;
If[Length[ca]=!=Length[cb]||dimsA=!=dimsB,Message[TensorTrainPlus::shape,dimsA,dimsB];Return[$Failed]];
(*a single core represents a vector;the sum is elementwise,no rank concept*)If[n==1,Return[TensorTrain[{ca[[1]]+cb[[1]]}]]];
cores=Table[With[{a=ca[[k]],b=cb[[k]],nk=dimsA[[k]]},Transpose[(*build per physical slice,then (left,phys,right)*)Table[Which[k==1,ArrayFlatten[{{a[[All,s,All]],b[[All,s,All]]}}],(*row:1 x (aR+bR)*)k==n,ArrayFlatten[{{a[[All,s,All]]},{b[[All,s,All]]}}],(*column:(aL+bL) x 1*)True,ArrayFlatten[{{a[[All,s,All]],0},{0,b[[All,s,All]]}}] (*block diagonal*)],{s,nk}],{2,1,3}]],{k,n}];
TensorTrain[cores]];

TensorTrainPlus[a_List,b_]:=With[{ta=TensorTrain[a]},If[ta===$Failed,$Failed,TensorTrainPlus[ta,b]]];
TensorTrainPlus[a_TensorTrain,b_List]:=With[{tb=TensorTrain[b]},If[tb===$Failed,$Failed,TensorTrainPlus[a,tb]]];


TensorTrainScale[c_,TensorTrain[cores_List]]:=TensorTrain[MapAt[c #&,cores,1]];
TensorTrainScale[c_,cores_List]:=With[{tt=TensorTrain[cores]},If[tt===$Failed,$Failed,TensorTrainScale[c,tt]]];
