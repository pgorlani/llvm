// RUN: mlir-opt %s -test-linalg-data-layout-propagation -split-input-file | FileCheck %s

#map0 = affine_map<(d0, d1) -> (d0, d1)>
func.func @dynamic_elem_pack(%arg0: tensor<?x?xf32>, %dest: tensor<?x?x8x2xf32>) -> tensor<?x?x8x2xf32>
{
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %0 = tensor.dim %arg0, %c0 : tensor<?x?xf32>
  %1 = tensor.dim %arg0, %c1 : tensor<?x?xf32>
  %2 = tensor.empty(%0, %1) : tensor<?x?xf32>
  %3 = linalg.generic {indexing_maps = [#map0, #map0], iterator_types = ["parallel", "parallel"]}
      ins(%arg0 : tensor<?x?xf32>)
      outs(%2 : tensor<?x?xf32>) {
    ^bb0(%arg3: f32, %arg4: f32):
      %4 = arith.addf %arg3, %arg3 : f32
      linalg.yield %4 : f32
  } -> tensor<?x?xf32>
  %4 = tensor.pack %3
    inner_dims_pos = [0, 1]
    inner_tiles = [8, 2]
    into %dest : tensor<?x?xf32> -> tensor<?x?x8x2xf32>
  return %4 : tensor<?x?x8x2xf32>
}
// CHECK-DAG:  #[[MAP0:.+]] = affine_map<()[s0] -> (s0 ceildiv 8)>
// CHECK-DAG:  #[[MAP1:.+]] = affine_map<()[s0] -> (s0 ceildiv 2)>
// CHECK-DAG:  #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
// CHECK:      func.func @dynamic_elem_pack
// CHECK-SAME:   %[[ARG0:[a-zA-Z0-9]+]]
// CHECK-SAME:   %[[DEST:[a-zA-Z0-9]+]]
// CHECK-DAG:    %[[C0:.+]] = arith.constant 0 : index
// CHECK-DAG:    %[[C1:.+]] = arith.constant 1 : index
// CHECK-DAG:    %[[D0:.+]] = tensor.dim %[[ARG0]], %[[C0]]
// CHECK-DAG:    %[[D1:.+]] = tensor.dim %[[ARG0]], %[[C1]]
// CHECK-DAG:    %[[OUTER_D0:.+]] = affine.apply #[[MAP0]]()[%[[D0]]]
// CHECK-DAG:    %[[OUTER_D1:.+]] = affine.apply #[[MAP1]]()[%[[D1]]]
// CHECK:        %[[ARG0_EMPTY:.+]] = tensor.empty(%[[OUTER_D0]], %[[OUTER_D1]]) : tensor<?x?x8x2xf32>
// CHECK:        %[[PACK_ARG0:.+]] = tensor.pack %[[ARG0]]
// CHECK-SAME:     inner_dims_pos = [0, 1] inner_tiles = [8, 2]
// CHECK-SAME:     into %[[ARG0_EMPTY]]
// CHECK:        %[[ELEM:.+]] = linalg.generic
// CHECK-SAME:     indexing_maps = [#[[MAP2]], #[[MAP2]]]
// CHECK-SAME:     iterator_types = ["parallel", "parallel", "parallel", "parallel"]
// CHECK-SAME:     ins(%[[PACK_ARG0]]
// CHECK-SAME:     outs(%[[DEST]]
// CHECK:        return %[[ELEM]] : tensor<?x?x8x2xf32>

// -----

#map0 = affine_map<(d0, d1) -> (d0, d1)>
func.func @elem_pack_transpose_inner_dims(%arg0: tensor<128x256xi32>, %dest: tensor<4x16x16x32xi32>) -> tensor<4x16x16x32xi32>{
  %init = tensor.empty() : tensor<128x256xi32>
  %elem = linalg.generic {indexing_maps = [#map0, #map0], iterator_types = ["parallel", "parallel"]}
      ins(%arg0 : tensor<128x256xi32>)
      outs(%init : tensor<128x256xi32>) {
    ^bb0(%arg3: i32, %arg4: i32):
      %4 = arith.addi %arg3, %arg3 : i32
      linalg.yield %4 : i32
  } -> tensor<128x256xi32>
  %pack = tensor.pack %elem
    inner_dims_pos = [1, 0]
    inner_tiles = [16, 32]
    into %dest : tensor<128x256xi32> -> tensor<4x16x16x32xi32>
  return %pack : tensor<4x16x16x32xi32>
}
// CHECK-DAG:  #[[MAP:.+]] = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
// CHECK:      func.func @elem_pack_transpose_inner_dims
// CHECK-SAME:   %[[ARG0:[a-zA-Z0-9]+]]
// CHECK-SAME:   %[[DEST:[a-zA-Z0-9]+]]
// CHECK:        %[[ARG0_EMPTY:.+]] = tensor.empty() : tensor<4x16x16x32xi32>
// CHECK:        %[[PACK_ARG0:.+]] = tensor.pack %[[ARG0]]
// CHECK-SAME:     inner_dims_pos = [1, 0] inner_tiles = [16, 32]
// CHECK-SAME:     into %[[ARG0_EMPTY]]
// CHECK:        %[[ELEM:.+]] = linalg.generic
// CHECK-SAME:     indexing_maps = [#[[MAP]], #[[MAP]]]
// CHECK-SAME:     iterator_types = ["parallel", "parallel", "parallel", "parallel"]
// CHECK-SAME:     ins(%[[PACK_ARG0]]
// CHECK-SAME:     outs(%[[DEST]]
// CHECK:        return %[[ELEM]] : tensor<4x16x16x32xi32>

// -----

#map0 = affine_map<(d0, d1) -> (d0, d1)>
func.func @elem_pack_transpose_outer_dims(%arg0: tensor<128x256xi32>, %dest: tensor<16x4x32x16xi32>) -> tensor<16x4x32x16xi32>{
  %init = tensor.empty() : tensor<128x256xi32>
  %elem = linalg.generic {indexing_maps = [#map0, #map0], iterator_types = ["parallel", "parallel"]}
      ins(%arg0 : tensor<128x256xi32>)
      outs(%init : tensor<128x256xi32>) {
    ^bb0(%arg3: i32, %arg4: i32):
      %4 = arith.addi %arg3, %arg3 : i32
      linalg.yield %4 : i32
  } -> tensor<128x256xi32>
  %pack = tensor.pack %elem
    outer_dims_perm = [1, 0]
    inner_dims_pos = [0, 1]
    inner_tiles = [32, 16]
    into %dest : tensor<128x256xi32> -> tensor<16x4x32x16xi32>
  return %pack : tensor<16x4x32x16xi32>
}
// CHECK-DAG:  #[[MAP:.+]] = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
// CHECK:      func.func @elem_pack_transpose_outer_dims
// CHECK-SAME:   %[[ARG0:[a-zA-Z0-9]+]]
// CHECK-SAME:   %[[DEST:[a-zA-Z0-9]+]]
// CHECK:        %[[ARG0_EMPTY:.+]] = tensor.empty() : tensor<16x4x32x16xi32>
// CHECK:        %[[PACK_ARG0:.+]] = tensor.pack %[[ARG0]]
// CHECK-SAME:     outer_dims_perm = [1, 0] inner_dims_pos = [0, 1] inner_tiles = [32, 16]
// CHECK-SAME:     into %[[ARG0_EMPTY]]
// CHECK:        %[[ELEM:.+]] = linalg.generic
// CHECK-SAME:     indexing_maps = [#[[MAP]], #[[MAP]]]
// CHECK-SAME:     iterator_types = ["parallel", "parallel", "parallel", "parallel"]
// CHECK-SAME:     ins(%[[PACK_ARG0]]
// CHECK-SAME:     outs(%[[DEST]]
// CHECK:        return %[[ELEM]] : tensor<16x4x32x16xi32>

// -----

#map0 = affine_map<(d0, d1) -> (d0, d1)>
func.func @elem_pack_transpose_inner_and_outer_dims(%arg0: tensor<128x256xi32>, %dest: tensor<16x4x16x32xi32>) -> tensor<16x4x16x32xi32>{
  %init = tensor.empty() : tensor<128x256xi32>
  %elem = linalg.generic {indexing_maps = [#map0, #map0], iterator_types = ["parallel", "parallel"]}
      ins(%arg0 : tensor<128x256xi32>)
      outs(%init : tensor<128x256xi32>) {
    ^bb0(%arg3: i32, %arg4: i32):
      %4 = arith.addi %arg3, %arg3 : i32
      linalg.yield %4 : i32
  } -> tensor<128x256xi32>
  %pack = tensor.pack %elem
    outer_dims_perm = [1, 0]
    inner_dims_pos = [1, 0]
    inner_tiles = [16, 32]
    into %dest : tensor<128x256xi32> -> tensor<16x4x16x32xi32>
  return %pack : tensor<16x4x16x32xi32>
}
// CHECK-DAG:  #[[MAP:.+]] = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
// CHECK:      func.func @elem_pack_transpose_inner_and_outer_dims
// CHECK-SAME:   %[[ARG0:[a-zA-Z0-9]+]]
// CHECK-SAME:   %[[DEST:[a-zA-Z0-9]+]]
// CHECK:        %[[ARG0_EMPTY:.+]] = tensor.empty() : tensor<16x4x16x32xi32>
// CHECK:        %[[PACK_ARG0:.+]] = tensor.pack %[[ARG0]]
// CHECK-SAME:     outer_dims_perm = [1, 0] inner_dims_pos = [1, 0] inner_tiles = [16, 32]
// CHECK-SAME:     into %[[ARG0_EMPTY]]
// CHECK:        %[[ELEM:.+]] = linalg.generic
// CHECK-SAME:     indexing_maps = [#[[MAP]], #[[MAP]]]
// CHECK-SAME:     iterator_types = ["parallel", "parallel", "parallel", "parallel"]
// CHECK-SAME:     ins(%[[PACK_ARG0]]
// CHECK-SAME:     outs(%[[DEST]]
// CHECK:        return %[[ELEM]] : tensor<16x4x16x32xi32>

// -----

#map0 = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d0)>
#map2 = affine_map<(d0, d1) -> (d1)>
func.func @dynamic_broadcast_pack(%arg0: tensor<?xf32>, %arg1: tensor<?xf32>, %dest: tensor<?x?x8x2xf32>) -> tensor<?x?x8x2xf32>
{
  %c0 = arith.constant 0 : index
  %0 = tensor.dim %arg0, %c0 : tensor<?xf32>
  %1 = tensor.dim %arg1, %c0 : tensor<?xf32>
  %2 = tensor.empty(%0, %1) : tensor<?x?xf32>
  %3 = linalg.generic {indexing_maps = [#map1, #map2, #map0], iterator_types = ["parallel", "parallel"]}
      ins(%arg0, %arg1 : tensor<?xf32>, tensor<?xf32>)
      outs(%2 : tensor<?x?xf32>) {
    ^bb0(%arg3: f32, %arg4: f32, %arg5: f32):
      %4 = arith.addf %arg3, %arg4 : f32
      linalg.yield %4 : f32
  } -> tensor<?x?xf32>
  %4 = tensor.pack %3
    inner_dims_pos = [0, 1]
    inner_tiles = [8, 2]
    into %dest : tensor<?x?xf32> -> tensor<?x?x8x2xf32>
  return %4 : tensor<?x?x8x2xf32>
}
// CHECK-DAG:  #[[MAP0:.+]] = affine_map<()[s0] -> (s0 ceildiv 8)>
// CHECK-DAG:  #[[MAP1:.+]] = affine_map<()[s0] -> (s0 ceildiv 2)>
// CHECK-DAG:  #[[MAP2:.+]] = affine_map<(d0, d1, d2, d3) -> (d0, d2)>
// CHECK-DAG:  #[[MAP3:.+]] = affine_map<(d0, d1, d2, d3) -> (d1, d3)>
// CHECK-DAG:  #[[MAP4:.+]] = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
// CHECK:      func.func @dynamic_broadcast_pack
// CHECK-SAME:   %[[ARG0:[a-zA-Z0-9]+]]
// CHECK-SAME:   %[[ARG1:[a-zA-Z0-9]+]]
// CHECK-SAME:   %[[DEST:[a-zA-Z0-9]+]]
// CHECK-DAG:    %[[C0:.+]] = arith.constant 0 : index
// CHECK-DAG:    %[[D0:.+]] = tensor.dim %[[ARG0]], %[[C0]]
// CHECK-DAG:    %[[OUTER_D0:.+]] = affine.apply #[[MAP0]]()[%[[D0]]]
// CHECK:        %[[ARG0_EMPTY:.+]] = tensor.empty(%[[OUTER_D0]]) : tensor<?x8xf32>
// CHECK:        %[[PACK_ARG0:.+]] = tensor.pack %[[ARG0]]
// CHECK-SAME:     inner_dims_pos = [0] inner_tiles = [8]
// CHECK-SAME:     into %[[ARG0_EMPTY]]
// CHECK-DAG:    %[[D1:.+]] = tensor.dim %[[ARG1]], %[[C0]]
// CHECK-DAG:    %[[OUTER_D1:.+]] = affine.apply #[[MAP1]]()[%[[D1]]]
// CHECK:        %[[ARG1_EMPTY:.+]] = tensor.empty(%[[OUTER_D1]]) : tensor<?x2xf32>
// CHECK:        %[[PACK_ARG1:.+]] = tensor.pack %[[ARG1]]
// CHECK-SAME:     inner_dims_pos = [0] inner_tiles = [2]
// CHECK-SAME:     into %[[ARG1_EMPTY]]
// CHECK:        %[[ELEM:.+]] = linalg.generic
// CHECK-SAME:     indexing_maps = [#[[MAP2]], #[[MAP3]], #[[MAP4]]]
// CHECK-SAME:     iterator_types = ["parallel", "parallel", "parallel", "parallel"]
// CHECK-SAME:     ins(%[[PACK_ARG0]], %[[PACK_ARG0]]
// CHECK-SAME:     outs(%[[DEST]]
// CHECK:        return %[[ELEM]] : tensor<?x?x8x2xf32>

// -----

#map0 = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d0)>
#map2 = affine_map<(d0, d1) -> (d1)>
func.func @transpose_pack(%arg0: tensor<100x128x200x256xi32>, %arg1: tensor<100xi32>, %arg2: tensor<128xi32>, %dest: tensor<100x200x4x16x16x32xi32>) -> tensor<100x200x4x16x16x32xi32>
{
  %init_transpose = tensor.empty() : tensor<100x200x128x256xi32>
  %transpose = linalg.generic {
      indexing_maps = [affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>,
                       affine_map<(d0, d1, d2, d3) -> (d0)>,
                       affine_map<(d0, d1, d2, d3) -> (d1)>,
                       affine_map<(d0, d1, d2, d3) -> (d0, d2, d1, d3)>],
      iterator_types = ["parallel", "parallel", "parallel", "parallel"]}
      ins(%arg0, %arg1, %arg2 : tensor<100x128x200x256xi32>, tensor<100xi32>, tensor<128xi32>)
      outs(%init_transpose : tensor<100x200x128x256xi32>) {
    ^bb0(%b0 : i32, %b1 : i32, %b2 : i32, %b3 : i32):
      %0 = arith.addi %b0, %b1 : i32
      %1 = arith.addi %0, %b2 : i32
      linalg.yield %1 : i32
    } -> tensor<100x200x128x256xi32>
  %4 = tensor.pack %transpose
    inner_dims_pos = [3, 2]
    inner_tiles = [16, 32]
    into %dest : tensor<100x200x128x256xi32> -> tensor<100x200x4x16x16x32xi32>
  return %4 : tensor<100x200x4x16x16x32xi32>
}
// CHECK: func.func @transpose_pack
// CHECK:   linalg.generic
// CHECK:   tensor.pack
