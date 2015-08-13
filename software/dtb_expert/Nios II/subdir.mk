################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CC_SRCS += \
../FlashMemory.cc \
../SRecordReader.cc \
../debug.cc \
../dtb_config.cc \
../dtb_hal.cc \
../dtb_main.cc \
../ethernet.cc \
../pixel_dtb.cc \
../roctest.cc \
../rpc.cc \
../rpc_dtb.cc \
../ugerror.cc 

OBJS += \
./FlashMemory.o \
./SRecordReader.o \
./debug.o \
./dtb_config.o \
./dtb_hal.o \
./dtb_main.o \
./ethernet.o \
./pixel_dtb.o \
./roctest.o \
./rpc.o \
./rpc_dtb.o \
./ugerror.o 

CC_DEPS += \
./FlashMemory.d \
./SRecordReader.d \
./debug.d \
./dtb_config.d \
./dtb_hal.d \
./dtb_main.d \
./ethernet.d \
./pixel_dtb.d \
./roctest.d \
./rpc.d \
./rpc_dtb.d \
./ugerror.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: Cygwin C++ Compiler'
	g++ -U__USING_SJLJ_EXCEPTIONS__ -U__FLT_EVAL_METHOD__ -U_X86_ -U__FLT_DIG__ -U__FLT_EPSILON__ -U__FLT_MAX_EXP__ -U__LDBL_MIN_EXP__ -U__DBL_MIN__ -U__LDBL_EPSILON__ -U__SCHAR_MAX__ -U__DBL_MIN_10_EXP__ -U__INT_MAX__ -U__unix__ -U__DBL_DENORM_MIN__ -U__LONG_LONG_MAX__ -U_stdcall -U__REGISTER_PREFIX__ -U__DBL_HAS_INFINITY__ -U__SHRT_MAX__ -U__FLT_HAS_QUIET_NAN__ -U__DBL_MAX_10_EXP__ -U__tune_pentiumpro__ -U__LDBL_MIN__ -U__NO_INLINE__ -U__GNUC__ -U__FLT_MIN_EXP__ -U__LDBL_HAS_QUIET_NAN__ -U__tune_i686__ -U__LDBL_MANT_DIG__ -U__FLT_DENORM_MIN__ -U__CYGWIN__ -U__LDBL_DIG__ -U__LDBL_DENORM_MIN__ -U__unix -U__VERSION__ -Ui386 -U__fastcall -U__USER_LABEL_PREFIX__ -U__LONG_MAX__ -U__FLT_MIN_10_EXP__ -U__PTRDIFF_TYPE__ -U__i386__ -U__WCHAR_MAX__ -U__CHAR_BIT__ -U__cdecl -U__DBL_HAS_QUIET_NAN__ -U__GNUC_PATCHLEVEL__ -U__GXX_ABI_VERSION -U__DBL_MAX_EXP__ -U__WINT_TYPE__ -U__DBL_MIN_EXP__ -U__DBL_MANT_DIG__ -U__LDBL_HAS_INFINITY__ -U__FLT_MAX_10_EXP__ -U__FLT_MAX__ -U__CYGWIN32__ -U_fastcall -U__declspec(x) -U__i386 -U__LDBL_MIN_10_EXP__ -U__EXCEPTIONS -U__SIZE_TYPE__ -U__FLT_HAS_INFINITY__ -U__STDC_HOSTED__ -U__DECIMAL_DIG__ -U__WCHAR_UNSIGNED__ -U__LDBL_MAX_10_EXP__ -U_cdecl -U__DEPRECATED -U__GXX_WEAK__ -U__FLT_MIN__ -U__DBL_MAX__ -U__DBL_EPSILON__ -U__LDBL_MAX__ -U__FINITE_MATH_ONLY__ -U__LDBL_MAX_EXP__ -U__DBL_DIG__ -U__WCHAR_TYPE__ -U__FLT_MANT_DIG__ -U__GNUG__ -U__FLT_RADIX__ -U__GNUC_MINOR__ -Uunix -U__cplusplus -U__stdcall -O2 -g -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


