// RUN: %clangxx -ccc-print-phases --sysroot=%S/Inputs/SYCL -target x86_64-unknown-linux-gnu  -fsycl -fsycl-targets=nvptx64-nvidia-cuda  -Xsycl-target-backend  --cuda-gpu-arch=sm_80 --cuda-gpu-arch=sm_80 -c %s 2>&1 | FileCheck %s --check-prefix=DEFAULT-PHASES

// Test the correct placement of the offloading actions for compiling CUDA sources (*.cu) in SYCL.

// DEFAULT-PHASES:                +- 0: input, "{{.*}}", cuda, (device-sycl, sm_80)
// DEFAULT-PHASES:             +- 1: preprocessor, {0}, cuda-cpp-output, (device-sycl, sm_80)
// DEFAULT-PHASES:          +- 2: compiler, {1}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES:       +- 3: offload, "device-sycl (nvptx64-nvidia-cuda:sm_80)" {2}, ir
// DEFAULT-PHASES:       |        +- 4: input, "{{.*}}", cuda, (device-cuda, sm_80)
// DEFAULT-PHASES:       |     +- 5: preprocessor, {4}, cuda-cpp-output, (device-cuda, sm_80)
// DEFAULT-PHASES:       |  +- 6: compiler, {5}, ir, (device-cuda, sm_80)
// DEFAULT-PHASES:       |- 7: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {6}, ir
// DEFAULT-PHASES:    +- 8: linker, {3, 7}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES: +- 9: offload, "device-sycl (nvptx64-nvidia-cuda:sm_80)" {8}, ir
// DEFAULT-PHASES: |                    +- 10: input, "{{.*}}", cuda, (host-cuda-sycl)
// DEFAULT-PHASES: |                 +- 11: append-footer, {10}, cuda, (host-cuda-sycl)
// DEFAULT-PHASES: |              +- 12: preprocessor, {11}, cuda-cpp-output, (host-cuda-sycl)
// DEFAULT-PHASES: |           +- 13: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {12}, "device-sycl (nvptx64-nvidia-cuda:sm_80)" {2}, cuda-cpp-output
// DEFAULT-PHASES: |        +- 14: compiler, {13}, ir, (host-cuda-sycl)
// DEFAULT-PHASES: |        |        +- 15: backend, {6}, assembler, (device-cuda, sm_80)
// DEFAULT-PHASES: |        |     +- 16: assembler, {15}, object, (device-cuda, sm_80)
// DEFAULT-PHASES: |        |  +- 17: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {16}, object
// DEFAULT-PHASES: |        |  |- 18: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {15}, assembler
// DEFAULT-PHASES: |        |- 19: linker, {17, 18}, cuda-fatbin, (device-cuda)
// DEFAULT-PHASES: |     +- 20: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {14}, "device-cuda (nvptx64-nvidia-cuda)" {19}, ir
// DEFAULT-PHASES: |  +- 21: backend, {20}, assembler, (host-cuda-sycl)
// DEFAULT-PHASES: |- 22: assembler, {21}, object, (host-cuda-sycl)
// DEFAULT-PHASES: 23: clang-offload-bundler, {9, 22}, object, (host-cuda-sycl)



// RUN: %clangxx -ccc-print-phases --sysroot=%S/Inputs/SYCL --cuda-path=%S/Inputs/CUDA_111/usr/local/cuda -fsycl-libspirv-path=%S/Inputs/SYCL/lib/nvidiacl -target x86_64-unknown-linux-gnu -fsycl -fsycl-targets=nvptx64-nvidia-cuda  -Xsycl-target-backend  --cuda-gpu-arch=sm_80 --cuda-gpu-arch=sm_80 %s 2>&1 | FileCheck %s --check-prefix=DEFAULT-PHASES2

<<<<<<< HEAD
// DEFAULT-PHASES2:                     +- 0: input, "{{.*}}", cuda, (host-cuda)
// DEFAULT-PHASES2:                  +- 1: preprocessor, {0}, cuda-cpp-output, (host-cuda)
// DEFAULT-PHASES2:               +- 2: compiler, {1}, ir, (host-cuda)
// DEFAULT-PHASES2:               |                 +- 3: input, "{{.*}}", cuda, (device-cuda, sm_80)
// DEFAULT-PHASES2:               |              +- 4: preprocessor, {3}, cuda-cpp-output, (device-cuda, sm_80)
// DEFAULT-PHASES2:               |           +- 5: compiler, {4}, ir, (device-cuda, sm_80)
// DEFAULT-PHASES2:               |        +- 6: backend, {5}, assembler, (device-cuda, sm_80)
// DEFAULT-PHASES2:               |     +- 7: assembler, {6}, object, (device-cuda, sm_80)
// DEFAULT-PHASES2:               |  +- 8: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {7}, object
// DEFAULT-PHASES2:               |  |- 9: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {6}, assembler
// DEFAULT-PHASES2:               |- 10: linker, {8, 9}, cuda-fatbin, (device-cuda)
// DEFAULT-PHASES2:            +- 11: offload, "host-cuda (x86_64-unknown-linux-gnu)" {2}, "device-cuda (nvptx64-nvidia-cuda)" {10}, ir
// DEFAULT-PHASES2:         +- 12: backend, {11}, assembler, (host-cuda-sycl)
// DEFAULT-PHASES2:      +- 13: assembler, {12}, object, (host-cuda-sycl)
// DEFAULT-PHASES2:   +- 14: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {13}, object
// DEFAULT-PHASES2:+- 15: linker, {14}, image, (host-cuda-sycl)
// DEFAULT-PHASES2:|              +- 16: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {5}, ir
// DEFAULT-PHASES2:|           +- 17: linker, {16}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2:|           |     +- 18: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 19: clang-offload-unbundler, {18}, object
// DEFAULT-PHASES2:|           |- 20: offload, " (nvptx64-nvidia-cuda)" {19}, object
// DEFAULT-PHASES2:|           |     +- 21: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 22: clang-offload-unbundler, {21}, object
// DEFAULT-PHASES2:|           |- 23: offload, " (nvptx64-nvidia-cuda)" {22}, object
// DEFAULT-PHASES2:|           |     +- 24: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 25: clang-offload-unbundler, {24}, object
// DEFAULT-PHASES2:|           |- 26: offload, " (nvptx64-nvidia-cuda)" {25}, object
// DEFAULT-PHASES2:|           |     +- 27: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 28: clang-offload-unbundler, {27}, object
// DEFAULT-PHASES2:|           |- 29: offload, " (nvptx64-nvidia-cuda)" {28}, object
// DEFAULT-PHASES2:|           |     +- 30: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 31: clang-offload-unbundler, {30}, object
// DEFAULT-PHASES2:|           |- 32: offload, " (nvptx64-nvidia-cuda)" {31}, object
// DEFAULT-PHASES2:|           |     +- 33: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 34: clang-offload-unbundler, {33}, object
// DEFAULT-PHASES2:|           |- 35: offload, " (nvptx64-nvidia-cuda)" {34}, object
// DEFAULT-PHASES2:|           |     +- 36: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 37: clang-offload-unbundler, {36}, object
// DEFAULT-PHASES2:|           |- 38: offload, " (nvptx64-nvidia-cuda)" {37}, object
// DEFAULT-PHASES2:|           |     +- 39: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 40: clang-offload-unbundler, {39}, object
// DEFAULT-PHASES2:|           |- 41: offload, " (nvptx64-nvidia-cuda)" {40}, object
// DEFAULT-PHASES2:|           |     +- 42: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 43: clang-offload-unbundler, {42}, object
// DEFAULT-PHASES2:|           |- 44: offload, " (nvptx64-nvidia-cuda)" {43}, object
// DEFAULT-PHASES2:|           |     +- 45: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 46: clang-offload-unbundler, {45}, object
// DEFAULT-PHASES2:|           |- 47: offload, " (nvptx64-nvidia-cuda)" {46}, object
// DEFAULT-PHASES2:|           |     +- 48: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 49: clang-offload-unbundler, {48}, object
// DEFAULT-PHASES2:|           |- 50: offload, " (nvptx64-nvidia-cuda)" {49}, object
// DEFAULT-PHASES2:|           |     +- 51: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 52: clang-offload-unbundler, {51}, object
// DEFAULT-PHASES2:|           |- 53: offload, " (nvptx64-nvidia-cuda)" {52}, object
// DEFAULT-PHASES2:|           |     +- 54: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 55: clang-offload-unbundler, {54}, object
// DEFAULT-PHASES2:|           |- 56: offload, " (nvptx64-nvidia-cuda)" {55}, object
// DEFAULT-PHASES2:|           |     +- 57: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 58: clang-offload-unbundler, {57}, object
// DEFAULT-PHASES2:|           |- 59: offload, " (nvptx64-nvidia-cuda)" {58}, object
// DEFAULT-PHASES2:|           |     +- 60: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 61: clang-offload-unbundler, {60}, object
// DEFAULT-PHASES2:|           |- 62: offload, " (nvptx64-nvidia-cuda)" {61}, object
// DEFAULT-PHASES2:|           |     +- 63: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 64: clang-offload-unbundler, {63}, object
// DEFAULT-PHASES2:|           |- 65: offload, " (nvptx64-nvidia-cuda)" {64}, object
// DEFAULT-PHASES2:|           |     +- 66: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 67: clang-offload-unbundler, {66}, object
// DEFAULT-PHASES2:|           |- 68: offload, " (nvptx64-nvidia-cuda)" {67}, object
// DEFAULT-PHASES2:|           |     +- 69: input, "{{.*}}", object
// DEFAULT-PHASES2:|           |  +- 70: clang-offload-unbundler, {69}, object
// DEFAULT-PHASES2:|           |- 71: offload, " (nvptx64-nvidia-cuda)" {70}, object
// DEFAULT-PHASES2:|           |- 72: input, "{{.*}}nvidiacl{{.*}}", ir, (device-sycl, sm_80)
// DEFAULT-PHASES2:|           |- 73: input, "{{.*}}libdevice{{.*}}", ir, (device-sycl, sm_80)
// DEFAULT-PHASES2:|        +- 74: linker, {17, 20, 23, 26, 29, 32, 35, 38, 41, 44, 47, 50, 53, 56, 59, 62, 65, 68, 71, 72, 73}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2:|     +- 75: sycl-post-link, {74}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2:|     |  +- 76: file-table-tform, {75}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2:|     |  |  +- 77: backend, {76}, assembler, (device-sycl, sm_80)
// DEFAULT-PHASES2:|     |  |  |- 78: assembler, {77}, object, (device-sycl, sm_80)
// DEFAULT-PHASES2:|     |  |- 79: linker, {77, 78}, cuda-fatbin, (device-sycl, sm_80)
// DEFAULT-PHASES2:|     |- 80: foreach, {76, 79}, cuda-fatbin, (device-sycl, sm_80)
// DEFAULT-PHASES2:|  +- 81: file-table-tform, {75, 80}, tempfiletable, (device-sycl, sm_80)
// DEFAULT-PHASES2:|- 82: clang-offload-wrapper, {81}, object, (device-sycl, sm_80)
// DEFAULT-PHASES2:83: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {15}, "device-sycl (nvptx64-nvidia-cuda:sm_80)" {82}, image
=======
// DEFAULT-PHASES2:                            +- 0: input, "{{.*}}", cuda, (host-cuda-sycl)
// DEFAULT-PHASES2:                         +- 1: append-footer, {0}, cuda, (host-cuda-sycl)
// DEFAULT-PHASES2:                      +- 2: preprocessor, {1}, cuda-cpp-output, (host-cuda-sycl)
// DEFAULT-PHASES2:                      |     +- 3: input, "{{.*}}", cuda, (device-sycl, sm_80)
// DEFAULT-PHASES2:                      |  +- 4: preprocessor, {3}, cuda-cpp-output, (device-sycl, sm_80)
// DEFAULT-PHASES2:                      |- 5: compiler, {4}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2:                   +- 6: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {2}, "device-sycl (nvptx64-nvidia-cuda:sm_80)" {5}, cuda-cpp-output
// DEFAULT-PHASES2:                +- 7: compiler, {6}, ir, (host-cuda-sycl)
// DEFAULT-PHASES2:                |                 +- 8: input, "{{.*}}", cuda, (device-cuda, sm_80)
// DEFAULT-PHASES2:                |              +- 9: preprocessor, {8}, cuda-cpp-output, (device-cuda, sm_80)
// DEFAULT-PHASES2:                |           +- 10: compiler, {9}, ir, (device-cuda, sm_80)
// DEFAULT-PHASES2:                |        +- 11: backend, {10}, assembler, (device-cuda, sm_80)
// DEFAULT-PHASES2:                |     +- 12: assembler, {11}, object, (device-cuda, sm_80)
// DEFAULT-PHASES2:                |  +- 13: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {12}, object
// DEFAULT-PHASES2:                |  |- 14: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {11}, assembler
// DEFAULT-PHASES2:                |- 15: linker, {13, 14}, cuda-fatbin, (device-cuda)
// DEFAULT-PHASES2:             +- 16: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {7}, "device-cuda (nvptx64-nvidia-cuda)" {15}, ir
// DEFAULT-PHASES2:          +- 17: backend, {16}, assembler, (host-cuda-sycl)
// DEFAULT-PHASES2:       +- 18: assembler, {17}, object, (host-cuda-sycl)
// DEFAULT-PHASES2:    +- 19: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {18}, object
// DEFAULT-PHASES2: +- 20: linker, {19}, image, (host-cuda-sycl)
// DEFAULT-PHASES2: |           |- 21: offload, "device-cuda (nvptx64-nvidia-cuda:sm_80)" {10}, ir
// DEFAULT-PHASES2: |        +- 22: linker, {5, 21}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2: |     +- 23: sycl-post-link, {22}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2: |     |  +- 24: file-table-tform, {23}, ir, (device-sycl, sm_80)
// DEFAULT-PHASES2: |     |  |  +- 25: backend, {24}, assembler, (device-sycl, sm_80)
// DEFAULT-PHASES2: |     |  |  |- 26: assembler, {25}, object, (device-sycl, sm_80)
// DEFAULT-PHASES2: |     |  |- 27: linker, {25, 26}, cuda-fatbin, (device-sycl, sm_80)
// DEFAULT-PHASES2: |     |- 28: foreach, {24, 27}, cuda-fatbin, (device-sycl, sm_80)
// DEFAULT-PHASES2: |  +- 29: file-table-tform, {23, 28}, tempfiletable, (device-sycl, sm_80)
// DEFAULT-PHASES2: |- 30: clang-offload-wrapper, {29}, object, (device-sycl, sm_80)
// DEFAULT-PHASES2: 31: offload, "host-cuda-sycl (x86_64-unknown-linux-gnu)" {20}, "device-sycl (nvptx64-nvidia-cuda:sm_80)" {30}, image
>>>>>>> 716f5d94b697 (fix sycl-cuda-tu-offload.cu)
