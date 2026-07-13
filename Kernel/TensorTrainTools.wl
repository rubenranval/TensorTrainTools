(* ::Package:: *)

(* ::Section:: *)
(*Package Header*)


BeginPackage["RubenRanval`TensorTrainTools`"];


(* ::Text:: *)
(*Declare your public symbols here:*)


TensorTrain::usage = "TensorTrain[cores] represents a tensor train."
TensorTrainDecomposition::usage="TensorTrainDecomposition[tensor] decomposes the numeric array tensor into a tensor train, a list of rank-3 cores {A1, ..., An}.";
TensorTrainContract::usage="TensorTrainContract[tt] contracts a tensor train (a TensorTrain object, or a list of rank-3 cores {A1, ..., An}) into the dense array it represents.";
TensorTrainCompress::usage="TensorTrainCompress[TensorTrain] returns a tensor train approximating TensorTrain with smaller bond dimensions, by right-orthogonalizing and then truncating each bond with an SVD sweep. Tolerance -> eps discards the smallest singular values whose total squared weight stays below eps^2 at each bond; \"MaxBondDimension\" -> r caps every bond at r. With the defaults (Tolerance -> 0, \"MaxBondDimension\" -> Infinity) only exact-zero singular values are removed, so redundant ranks collapse losslessly.";
TensorTrainOrthogonalize::usage="TensorTrainOrthogonalize[TensorTrain] returns the tensor train TensorTrain in left-canonical form: cores 1..n-1 are made left-orthogonal by a QR sweep while the tensor represented is left unchanged. The option \"Direction\" -> \"Right\" gives right-canonical form (cores 2..n right-orthogonal) instead.";
TensorTrainNorm::usage="TensorTrainNorm[TensorTrain] gives the Frobenius (Euclidean) norm of the tensor represented by the tensor train TensorTrain, computed by left-orthogonalizing and taking the norm of the single remaining core, without forming the dense tensor. The result is real and non-negative even for complex-valued trains.";
TensorTrainInnerProduct::usage="TensorTrainInnerProduct[a, b] gives the inner product <a|b> = Sum conj(a[i]) b[i] of two tensor trains representing tensors of the same dimensions, contracted without forming the dense tensors. It is conjugate-linear in the first argument, and TensorTrainInnerProduct[a, a] equals TensorTrainNorm[a]^2.";
TensorTrainHadamard::usage="TODO TensorTrainHadamard";
TensorTrainPlus::usage="TensorTrainPlus[a, b] gives the tensor train representing the sum of the tensors a and b, which must have the same dimensions. The cores are stacked block-diagonally, so the bond dimensions add.";
TensorTrainScale::usage="TensorTrainScale[c, tt] gives the tensor train representing c times the tensor tt, for a scalar c, by scaling a single core. The bond dimensions are unchanged.";
RandomTensorTrain::usage="RandomTensorTrain[{n1, ..., nd}] gives a random tensor train representing a tensor of dimensions n1*...*nd. RandomTensorTrain[{n1, ..., nd}, chi] sets every bond dimension to chi; RandomTensorTrain[{n1, ..., nd}, {chi1, ..., chi(d-1)}] sets the bonds individually. Cores are filled with random reals in [-1, 1]; the option \"Complex\" -> True fills them with random complex entries instead.";


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
