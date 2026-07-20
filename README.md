# TensorTrainTools

A work in progress... (v1)

Roadmap for v2: Support for GPU with GPUArray. GPU support for tensor train arithmetic.

____

Wolfram Language paclet for tensor train (MPS) decomposition, compression, and arithmetic.

A tensor train represents a rank-*d* tensor as a chain of *d* rank-3 cores, so storage scales as O(*d n χ²*) in the bond dimension *χ* instead of O(*n^d*). Tensors that are smooth, low-rank, or weakly correlated are often representable by a few thousand parameters, even when the dense array would have billions of entries.

**[Full up to date documentation available here](https://resources.wolframcloud.com/PacletRepository/resources/RubenRanval/TensorTrainTools/)**

## Installation

```wolfram
PacletInstall["RubenRanval/TensorTrainTools"]
Needs["RubenRanval`TensorTrainTools`"]
```

## Quick start

Decompose a dense array. `Sin[x + y + z]` has tensor-train rank 2, which the decomposition discovers automatically:

```wolfram
t = N @ Table[Sin[x + y + z], {x, 20}, {y, 20}, {z, 20}];
tt = TensorTrainDecomposition[t, Tolerance -> 1*^-10];

tt["BondDimensions"]      
tt["CompressionRatio"]     
Max @ Abs[Normal[tt] - t]   
```

Arithmetic stays in the compressed format, using ordinary operators:

```wolfram
a = RandomTensorTrain[{2, 3, 4, 3, 2}, 3];
b = RandomTensorTrain[{2, 3, 4, 3, 2}, 2];

s = 2 a - b;                           
h = a ⊙ b;                   
TensorTrainCompress[s, Tolerance -> 1*^-12]
```

Results are exact but not compressed, so `TensorTrainCompress` is the idiom for restoring minimal ranks after arithmetic.

Norms and inner products never form the dense tensor:

```wolfram
big = RandomTensorTrain[ConstantArray[2, 40], Join[{2}, ConstantArray[4, 37], {2}]];

big["FullElementCount"]     
big["ParameterCount"]     
TensorTrainNorm[big]
```

## Functions

| | |
|---|---|
| `TensorTrain`, `RandomTensorTrain` | construction |
| `TensorTrainDecomposition`, `TensorTrainContract` | conversion to and from dense arrays |
| `TensorTrainCompress`, `TensorTrainOrthogonalize`, `TensorTrainNorm` | rank control and canonical forms |
| `TensorTrainPlus`, `TensorTrainScale`, `TensorTrainHadamard`, `TensorTrainInnerProduct` | arithmetic |
| `MPOApply` | matrix product operators |

Operators `+`, `-`, `c t`, and `⊙` map to the corresponding functions when every operand is a tensor train.

## References

- I. V. Oseledets, "Tensor-Train Decomposition," *SIAM J. Sci. Comput.* **33**(5), 2295–2317 (2011). [doi:10.1137/090752286](https://doi.org/10.1137/090752286)
- I. V. Oseledets and E. E. Tyrtyshnikov, "Breaking the curse of dimensionality, or how to use SVD in many dimensions," *SIAM J. Sci. Comput.* **31**(5), 3744–3759 (2009). [doi:10.1137/090748330](https://doi.org/10.1137/090748330)
- U. Schollwöck, "The density-matrix renormalization group in the age of matrix product states," *Ann. Phys.* **326**(1), 96–192 (2011).

## License

MIT License

Copyright (c) 2026 Ruben Ranval

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
