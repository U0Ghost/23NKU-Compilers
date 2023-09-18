; ModuleID = 'vectordot.ll'
source_filename = "vectordot.ll"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@__const.main.vec1 = private unnamed_addr constant [3 x i32] [i32 1, i32 2, i32 3], align 4
@__const.main.vec2 = private unnamed_addr constant [3 x i32] [i32 4, i32 5, i32 6], align 4
@.str = private unnamed_addr constant [17 x i8] c"Dot product: %d\0A\00", align 1

define dso_local i32 @vectordot(i32* %vector1, i32* %vector2, i32 %length) {
  %index = alloca i32*, align 8
  %result = alloca i32, align 4
  %i = alloca i32, align 4
  %partial_sum = alloca i32, align 4
  %zero = alloca i32, align 4
  store i32* %vector1, i32** %index, align 8
  store i32 0, i32* %partial_sum, align 4
  store i32 0, i32* %i, align 4
  store i32 0, i32* %zero, align 4
  br label %start_loop

start_loop:                                       ; preds = %update_loop, %0
  %current_i = load i32, i32* %i, align 4
  %loop_condition = icmp slt i32 %current_i, %length
  br i1 %loop_condition, label %loop_body, label %end_loop

loop_body:                                        ; preds = %start_loop
  %vector_ptr1 = load i32*, i32** %index, align 8
  %i2 = load i32, i32* %i, align 4
  %index_ptr1 = sext i32 %i2 to i64
  %element1_ptr = getelementptr inbounds i32, i32* %vector_ptr1, i64 %index_ptr1
  %element1 = load i32, i32* %element1_ptr, align 4
  %vector_ptr2 = load i32*, i32** %index, align 8
  %i3 = load i32, i32* %i, align 4
  %index_ptr2 = sext i32 %i3 to i64
  %element2_ptr = getelementptr inbounds i32, i32* %vector_ptr2, i64 %index_ptr2
  %element2 = load i32, i32* %element2_ptr, align 4
  %product = mul nsw i32 %element1, %element2
  %current_sum = load i32, i32* %partial_sum, align 4
  %new_sum = add nsw i32 %current_sum, %product
  store i32 %new_sum, i32* %partial_sum, align 4
  br label %update_loop

update_loop:                                      ; preds = %loop_body
  %nowi = load i32, i32* %i, align 4
  %new_i = add nsw i32 %nowi, 1
  store i32 %new_i, i32* %i, align 4
  br label %start_loop

end_loop:                                         ; preds = %start_loop
  %final_result = load i32, i32* %partial_sum, align 4
  ret i32 %final_result
}

define dso_local i32 @main() {
  %result = alloca i32, align 4
  %vector1 = alloca [3 x i32], align 4
  %vector2 = alloca [3 x i32], align 4
  %length = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, i32* %result, align 4
  %vector_ptr1 = bitcast [3 x i32]* %vector1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %vector_ptr1, i8* align 4 bitcast ([3 x i32]* @__const.main.vec1 to i8*), i64 12, i1 false)
  %vector_ptr2 = bitcast [3 x i32]* %vector2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %vector_ptr2, i8* align 4 bitcast ([3 x i32]* @__const.main.vec2 to i8*), i64 12, i1 false)
  store i32 3, i32* %length, align 4
  store i32 0, i32* %i, align 4
  %vector1_ptr = getelementptr inbounds [3 x i32], [3 x i32]* %vector1, i64 0, i64 0
  %vector2_ptr = getelementptr inbounds [3 x i32], [3 x i32]* %vector2, i64 0, i64 0
  %length_val = load i32, i32* %length, align 4
  %result_val = call i32 @vectordot(i32* %vector1_ptr, i32* %vector2_ptr, i32 %length_val)
  store i32 %result_val, i32* %result, align 4
  %final_result = load i32, i32* %result, align 4
  %print_result = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str, i64 0, i64 0), i32 %final_result)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #0

declare dso_local i32 @printf(i8*, ...)

attributes #0 = { argmemonly nounwind willreturn }
