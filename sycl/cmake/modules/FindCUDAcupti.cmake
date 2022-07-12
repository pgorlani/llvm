macro(find_cuda_cupti _cupti_LIBRARY)
  # The following if can be removed when FindCUDA -> FindCUDAToolkit
    find_library(_cupti_LIBRARY
      NAMES cupti
      HINTS ${CUDA_TOOLKIT_ROOT_DIR}
            ENV CUDA_PATH
      PATH_SUFFIXES nvidia/current lib64 lib/x64 lib
                    ../extras/CUPTI/lib64/
                    ../extras/CUPTI/lib/
    )
endmacro()

