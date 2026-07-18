(* ::Package:: *)

(* ::Section:: *)
(*Package Header*)


BeginPackage["RubenRanval`TensorTrainTools`"];


(* ::Text:: *)
(*Declare your public symbols here:*)


TensorTrain::usage="TensorTrain[{\!\(\*SubscriptBox[\(A\), \(1\)]\), \[Ellipsis], \!\(\*SubscriptBox[\(A\), \(n\)]\)}] represents a tensor in tensor-train (matrix product) format with rank-3 cores \!\(\*SubscriptBox[\(A\), \(i\)]\)";
TensorTrainDecomposition::usage="TensorTrainDecomposition[array] gives a tensor train representing the numeric array";
TensorTrainContract::usage="TensorTrainContract[t] gives the dense array represented by the tensor train t, contracting all bond indices.";
TensorTrainOrthogonalize::usage="TensorTrainOrthogonalize[t] gives a tensor train representing the same tensor as t, with all cores but the last in left-orthonormal form.";
TensorTrainCompress::usage="TensorTrainCompress[t] gives a tensor train representing the same tensor as t with minimal bond dimensions";
TensorTrainNorm::usage="TensorTrainNorm[tt] gives the Frobenius norm of the tensor represented by the tensor train tt";
TensorTrainInnerProduct::usage="TensorTrainInnerProduct[a, b] gives the inner product of the tensors represented by the tensor trains a and b";
TensorTrainPlus::usage="TensorTrainPlus[\!\(\*SubscriptBox[\(t\), \(1\)]\), \!\(\*SubscriptBox[\(t\), \(2\)]\), \[Ellipsis]] gives the sum of the tensor trains \!\(\*SubscriptBox[\(t\), \(i\)]\)";
TensorTrainScale::usage="TensorTrainScale[c, t] gives the tensor train representing c times the tensor represented by t";
TensorTrainHadamard::usage="TensorTrainHadamard[\!\(\*SubscriptBox[\(t\), \(1\)]\), \!\(\*SubscriptBox[\(t\), \(2\)]\), \[Ellipsis]] gives the elementwise (Hadamard) product of the tensor trains \!\(\*SubscriptBox[\(t\), \(i\)]\)";
RandomTensorTrain::usage="RandomTensorTrain[{\!\(\*SubscriptBox[\(n\), \(1\)]\), \[Ellipsis], \!\(\*SubscriptBox[\(n\), \(d\)]\)}] gives a random tensor train representing a tensor of dimensions \!\(\*SubscriptBox[\(n\), \(1\)]\)\[Times]\[Ellipsis]\[Times]\!\(\*SubscriptBox[\(n\), \(d\)]\), with all bond dimensions 2";


Begin["`Private`"];


(* ::Section:: *)
(*Definitions*)


(* ::Text:: *)
(*Define your public and private symbols here:*)


Get["RubenRanval`TensorTrainTools`Construct`"];
Get["RubenRanval`TensorTrainTools`Arithmetic`"];
Get["RubenRanval`TensorTrainTools`Utilities`"];


(* ::Section:: *)
(*Package Footer*)


End[];
EndPackage[];
