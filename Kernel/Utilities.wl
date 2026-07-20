(* ::Package:: *)

ttValidMaxBondQ[chi_]:=chi===Infinity||(IntegerQ[chi]&&chi>=1);
ttValidToleranceQ[eps_]:=NumericQ[eps]&&!Negative[eps];
ttTruncationRank[sigma_,eps_,chimax_]:=
	Clip[Count[Reverse@Accumulate[Reverse[sigma^2]],x_/;x>eps^2],
		{1,Min[chimax,Length[sigma]]}];


(* ::Subsection:: *)
(* TensorTrainDecomposition *)


$defaultMaxBondDimension=Infinity;
$defaultTolerance=0;
$defaultMethod="SVD";

Options[TensorTrainDecomposition]={
	"MaxBondDimension"->$defaultMaxBondDimension,
	Tolerance->$defaultTolerance,
	Method->$defaultMethod
};

TensorTrainDecomposition::notarr="Input must be a numeric array.";
TensorTrainDecomposition::badchi="MaxBondDimension must be a positive integer or Infinity.";
TensorTrainDecomposition::badeps="Tolerance must be a non-negative number.";
TensorTrainDecomposition::badmeth="Method must be \"SVD\" or \"QR\".";

TensorTrainDecomposition[tensor_,opts:OptionsPattern[]]:=Module[
	{chimax=OptionValue["MaxBondDimension"],eps=OptionValue[Tolerance],method=OptionValue[Method],
	dims,d,residual,cores={},r=1,nk,restDims,U,S,V,q,Q,R,rNew,sigma},

	If[!ArrayQ[tensor,_,NumericQ],Message[TensorTrainDecomposition::notarr];Return[$Failed]];
	If[!ttValidMaxBondQ[chimax],Message[TensorTrainDecomposition::badchi];Return[$Failed]];
	If[!ttValidToleranceQ[eps],Message[TensorTrainDecomposition::badeps];Return[$Failed]];
	If[!MemberQ[{"SVD","QR"},method],Message[TensorTrainDecomposition::badmeth];Return[$Failed]];

	dims=Dimensions@tensor;
	d=Length@dims;
	residual=tensor;

	Do[
		nk=dims[[k]];
		restDims=Times@@Drop[dims,k];
		residual=ArrayReshape[residual,{r*nk,restDims}];

		Switch[method,
			"SVD",
			{U,S,V}=SingularValueDecomposition[residual,Min[Dimensions[residual]]];
			sigma=Diagonal@S;
			rNew=ttTruncationRank[sigma,eps,chimax];
			AppendTo[cores,ArrayReshape[U[[All,1;;rNew]],{r,nk,rNew}]];
			residual=S[[1;;rNew,1;;rNew]] . ConjugateTranspose[V[[All,1;;rNew]]],

			"QR",
			{q,R}=QRDecomposition[residual];
			Q=ConjugateTranspose[q];
			rNew=Dimensions[R][[1]];
			AppendTo[cores,ArrayReshape[Q,{r,nk,rNew}]];
			residual=R];
		r=rNew,
		{k,1,d-1}];

	AppendTo[cores,ArrayReshape[residual,{r,dims[[d]],1}]];
	TensorTrain@cores]


(* ::Subsection:: *)
(* TensorTrainContract *)


TensorTrainContract::notcores="Input must be a TensorTrain or a nonempty list of rank-3 arrays (tensor-train cores).";

TensorTrainContract[TensorTrain[cores_List]]:=
	ArrayReshape[Fold[Dot,First@cores,Rest@cores],Dimensions[#][[2]]&/@cores];
TensorTrainContract[cores_List]:=
	With[{tt=TensorTrain[cores]},If[tt===$Failed,$Failed,TensorTrainContract[tt]]];
TensorTrainContract[expr_]/;(Head[expr]=!=TensorTrain&&!ListQ[expr]):=
	(Message[TensorTrainContract::notcores];$Failed);


(* ::Subsection:: *)
(* TensorTrainOrthogonalize *)


TensorTrainOrthogonalize::dir="Direction must be \"Left\" or \"Right\".";

Options[TensorTrainOrthogonalize]={"Direction"->"Left"};

TensorTrainOrthogonalize[TensorTrain[cores_List],OptionsPattern[]]:=Module[
	{dir=OptionValue["Direction"],c=cores,n=Length[cores],chiL,nk,chiR,mat,q,r,qStd,rho},
	If[!MemberQ[{"Left","Right"},dir],Message[TensorTrainOrthogonalize::dir];Return[$Failed]];
	If[n==1,Return[TensorTrain[c]]];
	If[dir==="Left",
		Do[
			{chiL,nk,chiR}=Dimensions[c[[k]]];
			mat=ArrayReshape[c[[k]],{chiL*nk,chiR}];
			{q,r}=QRDecomposition[mat];
			qStd=ConjugateTranspose[q];
			rho=Dimensions[r][[1]];
			c[[k]]=ArrayReshape[qStd,{chiL,nk,rho}];
			c[[k+1]]=r . c[[k+1]],
			{k,1,n-1}],
		Do[
			{chiL,nk,chiR}=Dimensions[c[[k]]];
			mat=ArrayReshape[c[[k]],{chiL,nk*chiR}];
			{q,r}=QRDecomposition[ConjugateTranspose[mat]];
			rho=Dimensions[r][[1]];
			c[[k]]=ArrayReshape[q,{rho,nk,chiR}];
			c[[k-1]]=c[[k-1]] . ConjugateTranspose[r],
			{k,n,2,-1}]];
	TensorTrain[c]];

TensorTrainOrthogonalize[cores_List,opts:OptionsPattern[]]:=
	With[{tt=TensorTrain[cores]},If[tt===$Failed,$Failed,TensorTrainOrthogonalize[tt,opts]]];


(* ::Subsection:: *)
(* TensorTrainCompress *)


TensorTrainCompress::badchi="MaxBondDimension must be a positive integer or Infinity.";
TensorTrainCompress::badeps="Tolerance must be a non-negative number.";

Options[TensorTrainCompress]={"MaxBondDimension"->Infinity,Tolerance->0};

(* right-orthogonalize, then truncated-SVD sweep from the left *)
TensorTrainCompress[TensorTrain[cores_List],OptionsPattern[]]:=Module[
	{chimax=OptionValue["MaxBondDimension"],eps=OptionValue[Tolerance],
	c,n=Length[cores],chiL,nk,chiR,mat,u,s,v,sigma,rNew,carry},
	If[!ttValidMaxBondQ[chimax],Message[TensorTrainCompress::badchi];Return[$Failed]];
	If[!ttValidToleranceQ[eps],Message[TensorTrainCompress::badeps];Return[$Failed]];
	If[n==1,Return[TensorTrain[cores]]];
	c=TensorTrainOrthogonalize[TensorTrain[cores],"Direction"->"Right"]["Cores"];
	Do[
		{chiL,nk,chiR}=Dimensions[c[[k]]];
		mat=ArrayReshape[c[[k]],{chiL*nk,chiR}];
		{u,s,v}=SingularValueDecomposition[mat,Min[Dimensions[mat]]];
		sigma=Diagonal[s];
		rNew=ttTruncationRank[sigma,eps,chimax];
		c[[k]]=ArrayReshape[u[[All,1;;rNew]],{chiL,nk,rNew}];
		carry=s[[1;;rNew,1;;rNew]] . ConjugateTranspose[v[[All,1;;rNew]]];
		c[[k+1]]=carry . c[[k+1]],
		{k,1,n-1}];
	TensorTrain[c]];

TensorTrainCompress[cores_List,opts:OptionsPattern[]]:=
	With[{tt=TensorTrain[cores]},If[tt===$Failed,$Failed,TensorTrainCompress[tt,opts]]];


(* ::Subsection:: *)
(* TensorTrainNorm *)


(*left-orthogonalize then the Frobenius norm is the Euclidean norm of the one non-orthogonal core*)
TensorTrainNorm[TensorTrain[cores_List]]:=Module[{c},
	c=TensorTrainOrthogonalize[TensorTrain[cores],"Direction"->"Left"]["Cores"];
	Norm[Flatten[Last[c]]]];

TensorTrainNorm[cores_List]:=
	With[{tt=TensorTrain[cores]},If[tt===$Failed,$Failed,TensorTrainNorm[tt]]];


(* ::Subsection:: *)
(* RandomTensorTrain *)


RandomTensorTrain::baddims="Physical dimensions must be a nonempty list of positive integers.";
RandomTensorTrain::badbonds="Bond dimensions must be a positive integer or a list of `1` positive integers.";
RandomTensorTrain::infeasible="Requested bonds `1` exceed the maximal achievable ranks `2`; the represented tensor will have lower true rank at those bonds.";

Options[RandomTensorTrain]={"Complex"->False};

RandomTensorTrain[physDims_List,bondDims:(_Integer|{__Integer}),OptionsPattern[]]:=Module[
	{d=Length[physDims],bonds,fullBonds,total,prefix,maxBonds,gen},
	If[physDims==={}||!VectorQ[physDims,IntegerQ[#]&&#>=1&],
		Message[RandomTensorTrain::baddims];Return[$Failed]];
	bonds=Which[
		d==1,{},
		IntegerQ[bondDims]&&bondDims>=1,ConstantArray[bondDims,d-1],
		VectorQ[bondDims,#>=1&]&&Length[bondDims]==d-1,bondDims,
		True,Message[RandomTensorTrain::badbonds,d-1];Return[$Failed]];
	If[d>1,
		total=Times@@physDims;
		prefix=Rest@FoldList[Times,1,physDims];
		maxBonds=Table[Min[prefix[[k]],total/prefix[[k]]],{k,d-1}];
		If[Or@@MapThread[#1>#2&,{bonds,maxBonds}],
			Message[RandomTensorTrain::infeasible,bonds,maxBonds]]];
	fullBonds=Join[{1},bonds,{1}];
	gen=If[TrueQ[OptionValue["Complex"]],
		RandomReal[{-1,1},#]+I RandomReal[{-1,1},#]&,
		RandomReal[{-1,1},#]&];
	TensorTrain[Table[gen[{fullBonds[[k]],physDims[[k]],fullBonds[[k+1]]}],{k,d}]]];

RandomTensorTrain[physDims_List,opts:OptionsPattern[]]:=
	RandomTensorTrain[physDims,2,opts];
