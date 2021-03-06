#!/usr/bin/bash

function run_compilation() {

    compiler=$1
    # intercept compilation, ignore linking
    intercept_compilation=false
    ARGS=()
    IR_FILES=()
    INPUT_ARGS=("$@")
    IGNORE_NEXT_ARG=false
    for i in $(seq 1 $#);
    do
        var=${INPUT_ARGS[$i]}
        #echo $var ${IGNORE_NEXT_ARG}
        #echo $intercept_compilation
        # why was it =~?
        if [[ "$var" == "-c" ]]; then
            intercept_compilation=true
        fi
        if [[ ! "$var" == "-o" ]]; then
            if ! ${IGNORE_NEXT_ARG}; then
                #echo "Add"
                ARGS+=("$var")
            else
                IGNORE_NEXT_ARG=false
            fi         
        else
            IGNORE_NEXT_ARG=true
            ARGS+=("$var")
            i=$((i+1)) 
            var=${INPUT_ARGS[$i]}
            #echo "$var"
            dirname=$(dirname -- "$var")
            filename=$(basename -- "$var")
            filename="${filename%.*}"
            #echo "${dirname}/${filename}.ll"
            IR_FILES+=("${dirname}/${filename}.bc")
            ARGS+=("${dirname}/${filename}.bc")
        fi
    done
    echo ${ARGS[@]}
    #echo $intercept_compilation
    if [ "$intercept_compilation" == true ]; then
        shopt -s nocasematch
        echo "Run LLVM generation with flags: ${ARGS[@]}"
        ${LLVM_INSTALL_DIRECTORY}/bin/${compiler} "${@:2}"
        ${LLVM_INSTALL_DIRECTORY}/bin/${compiler} -emit-llvm "${ARGS[@]}"
        #for var in "${ARGS[@]}"
        #do
        #    if [[ "$var" =~ ".cpp" ]] || [[ "$var" =~ ".c" ]] ; then
        #        dirname=$(dirname -- "$var")
        #        filename=$(basename -- "$var")
        #        filename="${filename%.*}"
        #        echo "Run LLVM generation with flags: ${ARGS[@]}"
        #        ${LLVM_INSTALL_DIRECTORY}/bin/${compiler} "${@:2}"
        #        ${LLVM_INSTALL_DIRECTORY}/bin/${compiler} -S -emit-llvm "${ARGS[@]}"
        #        echo "${LLVM_INSTALL_DIRECTORY}/bin/${compiler} -S -emit-llvm "${ARGS[@]}" "${IR_FILES[@]}""
        #        #${LLVM_INSTALL_DIRECTORY}/bin/clang "$@" 
        #        #${LLVM_INSTALL_DIRECTORY}/bin/clang -S -emit-llvm "${ARGS[@]}"
        #        #${LLVM_INSTALL_DIRECTORY}/bin/opt -load ${LLVM_TOOL_DIRECTORY}/libLLVMLoopStatistics.so -loop-statistics -loop-statistics-out-dir ${OUT_DIR} -loop-statistics-log-name "$filename" < "$filename.ll" > /dev/null
        #    fi
        #done
    else
        #echo "Run linking with flags: "${IR_FILES[@]}""
        "${LLVM_INSTALL_DIRECTORY}/bin/${compiler}" "${@:2}"
        #${LLVM_INSTALL_DIRECTORY}/bin/llvm-as "${IR_FILES[@]}"
    fi
}
