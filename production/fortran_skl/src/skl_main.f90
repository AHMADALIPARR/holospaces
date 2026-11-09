program skl_prod_main
  use skl_production
  use iso_fortran_env, only: real64, int32
  implicit none
  real(real64) :: input(4)
  real(real64), allocatable :: output(:)
  integer(int32) :: status

  input = [1.0_real64, 2.0_real64, 3.0_real64, 4.0_real64]
  call skl_pipeline_add_norm(input, output, status)
  if (status /= SKL_OK) then
    write(*,*) "FAIL status=", status
    stop 1
  end if
  write(*,*) "pipeline output:", output
  write(*,*) "PASS"
end program
