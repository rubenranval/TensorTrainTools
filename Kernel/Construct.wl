(* ::Package:: *)

TensorTrain::notcores="A tensor train must be a nonempty list of rank-3 cores {A1, ..., An}.";
TensorTrain::bond="Inconsistent bond dimensions between cores `1` and `2`: `3` vs `4`.";
TensorTrain::bdry="Boundary bonds must both be 1, but are `1` (left) and `2` (right).";
TensorTrain::noprop="`1` is not a known property. Known properties: `2`.";


tensorTrainCoreListQ[cores_]:=MatchQ[cores,{__?(ArrayQ[#,3]&)}];

tensorTrainValidCoresQ[cores_]:=tensorTrainCoreListQ[cores]&&
	(Dimensions[#][[3]]&/@Most[cores])===(Dimensions[#][[1]]&/@Rest[cores])&&
	Dimensions[First@cores][[1]]===1&&Dimensions[Last@cores][[3]]===1;

tensorTrainIssueError[cores_]:=Module[{rb,lb,k},
	Which[
		!tensorTrainCoreListQ[cores],Message[TensorTrain::notcores],
		(rb=Dimensions[#][[3]]&/@Most[cores];
		lb=Dimensions[#][[1]]&/@Rest[cores];
		rb=!=lb),
		k=First@FirstPosition[MapThread[SameQ,{rb,lb}],False];
		Message[TensorTrain::bond,k,k+1,rb[[k]],lb[[k]]],
		True,Message[TensorTrain::bdry,Dimensions[First@cores][[1]],Dimensions[Last@cores][[3]]]]];


TensorTrain[cores_List]/;!tensorTrainValidCoresQ[cores]:=(tensorTrainIssueError[cores];$Failed);


tensorTrainData[cores_List]:=
Module[{phys,bonds,params},
	phys=Dimensions[#][[2]]&/@cores;
	bonds=Dimensions[#][[3]]&/@Most[cores];
	params=Total[Times@@@(Dimensions/@cores)];
	<|"Cores"->cores,
	"CoreCount"->Length[cores],
	"TensorDimensions"->phys,
	"BondDimensions"->bonds,
	"MaxBondDimension"->If[bonds==={},1,Max@bonds],
	"ParameterCount"->params,
	"FullElementCount"->Times@@phys,
	"CompressionRatio"->(Times@@phys)/params|>
];


TensorTrain[cores_List][prop_String]:=Module[{data=tensorTrainData[cores],all},
	all=Join[Keys@data,{"Tensor","Diagram","Properties"}];
	Which[
		KeyExistsQ[data,prop],data[prop],
		prop==="Tensor",TensorTrainContract[cores],
		prop==="Diagram",tensorTrainDiagram[cores],
		prop==="Properties",all,
		True,Message[TensorTrain::noprop,prop,all];$Failed]];


(* ::Subsection:: *)
(* Upvalues *)


TensorTrain/:Normal[TensorTrain[cores_List]]:=TensorTrainContract[cores];
TensorTrain/:Length[TensorTrain[cores_List]]:=Length[cores];


TensorTrain/:Plus[ts__TensorTrain]:=TensorTrainPlus[ts];
TensorTrain/:CircleDot[ts__TensorTrain]:=TensorTrainHadamard[ts];
TensorTrain/:Times[cs__?NumericQ,t_TensorTrain]:=TensorTrainScale[Times[cs],t];


(* ::Subsection:: *)
(* Formatting *)


TensorTrain/:MakeBoxes[tt:TensorTrain[cores_List],StandardForm]:=Module[{data=tensorTrainData[cores],icon},
	icon=tensorTrainDiagram[cores,"Labels"->False,ImageSize->{Automatic,40}];
	BoxForm`ArrangeSummaryBox[TensorTrain,tt,Deploy@icon,
		{BoxForm`SummaryItem[{"Cores: ",data["CoreCount"]}],
		BoxForm`SummaryItem[{"Max \[Chi]: ",data["MaxBondDimension"]}],
		BoxForm`SummaryItem[{"Tensor dims: ",data["TensorDimensions"]}]},
		{BoxForm`SummaryItem[{"Bond dimensions: ",data["BondDimensions"]}],
		BoxForm`SummaryItem[{"Stored elements: ",data["ParameterCount"]}],
		BoxForm`SummaryItem[{"Dense elements: ",data["FullElementCount"]}],
		BoxForm`SummaryItem[{"Compression: ",Row[{"\[Times]",Round[N@data["CompressionRatio"],0.1]}]}]},
		StandardForm]];


tensorTrainDiagram[cores_List,opts___Rule]:=Module[{n=Length@cores,bonds,phys,coreV,physV,edges,
	showLabels=Lookup[{opts},"Labels",True],size=Lookup[{opts},ImageSize,Automatic]},
	bonds=Dimensions[#][[3]]&/@Most[cores];
	phys=Dimensions[#][[2]]&/@cores;
	coreV=Table["c"<>ToString[k],{k,n}];
	physV=Table["p"<>ToString[k],{k,n}];
	edges=Join[Table[UndirectedEdge[coreV[[k]],coreV[[k+1]]],{k,n-1}],
		Table[UndirectedEdge[coreV[[k]],physV[[k]]],{k,n}]];
	Graph[Join[coreV,physV],edges,
		VertexCoordinates->Join[Table[{k,0},{k,n}],Table[{k,-0.8},{k,n}]],
		VertexSize->Join[Thread[coreV->0.5],Thread[physV->0.01]],
		VertexStyle->Join[Thread[coreV->RGBColor[0.35,0.55,0.85]],Thread[physV->GrayLevel[0.5]]],
		VertexLabels->If[showLabels,Table[coreV[[k]]->Placed[Subscript["A",k],Above],{k,n}],None],
		EdgeLabels->If[showLabels,
			Join[Table[UndirectedEdge[coreV[[k]],coreV[[k+1]]]->Placed[Style[bonds[[k]],9,RGBColor[0.7,0.2,0.2]],Center],{k,n-1}],
			Table[UndirectedEdge[coreV[[k]],physV[[k]]]->Placed[Style[phys[[k]],9,Gray],0.8],{k,n}]],
			None],
		EdgeStyle->Directive[Thick,GrayLevel[0.4]],
		PlotRangePadding->0.3,ImageSize->size]];
