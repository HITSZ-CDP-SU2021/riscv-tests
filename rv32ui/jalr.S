# See LICENSE for license details.

#*****************************************************************************
# jalr.S
#-----------------------------------------------------------------------------
#
# Test jalr instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Test 2: Basic test
  #-------------------------------------------------------------

test_2:
  li  TESTNUM, 2
  li  t0, 0
  lui t1, %hi(target_2)
  addi t1, t1, %lo(target_2)

  jalr t0, t1, 0
linkaddr_2:
  j fail

target_2:
  lui t1, %hi(linkaddr_2)
  addi t1, t1, %lo(linkaddr_2)
  bne t0, t1, fail

  #-------------------------------------------------------------
  # Test 3: Basic test2, rs = rd
  #-------------------------------------------------------------

test_3:
  li  TESTNUM, 3
  lui t0, %hi(target_3)
  addi t0, t0, %lo(target_3)

  jalr t0, t0, 0
linkaddr_3:
  j fail

target_3:
  lui t1, %hi(linkaddr_3)
  addi t1, t1, %lo(linkaddr_3)
  bne t0, t1, fail

  #-------------------------------------------------------------
  # Bypassing tests
  #-------------------------------------------------------------

  TEST_JALR_SRC1_BYPASS( 4, 0, jalr );
  TEST_JALR_SRC1_BYPASS( 5, 1, jalr );
  TEST_JALR_SRC1_BYPASS( 6, 2, jalr );

  #-------------------------------------------------------------
  # Test delay slot instructions not executed nor bypassed
  #-------------------------------------------------------------

  .option push
  .align 2
  .option norvc
  TEST_CASE( 7, t0, 4, \
    li  t0, 1; \
    lui t1, %hi(1f); \
    addi t1, t1, %lo(1f); \
    jr  t1, -4; \
    addi t0, t0, 1; \
    addi t0, t0, 1; \
    addi t0, t0, 1; \
    addi t0, t0, 1; \
1:  addi t0, t0, 1; \
    addi t0, t0, 1; \
  )
  .option pop

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
