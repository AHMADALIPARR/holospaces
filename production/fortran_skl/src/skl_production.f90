! Production SKL runtime kernel
! Deterministic VECTOR[F64] functor execution
! Mirrors just-gherkin-fortran/src/functor_runtime.f90 with explicit status codes

module skl_production
  use iso_fortran_env, only: real64, int32
  implicit none
  private

  integer(int32), parameter, public :: SKL_OK = 0
  integer(int32), parameter, public :: SKL_ERR_SIZE = 10
  integer(int32), parameter, public :: SKL_ERR_ZERO = 20
  integer(int32), parameter, public :: SKL_ERR_RESOLVE = 30

  public :: skl_add, skl_normalize, skl_identity, skl_pipeline_add_norm

contains

  pure subroutine skl_add(input, output, status)
    real(real64), intent(in) :: input(:)
    real(real64), allocatable, intent(out) :: output(:)
    integer(int32), intent(out) :: status
    integer :: n, i
    status = SKL_ERR_SIZE
    n = size(input)
    if (mod(n, 2) /= 0) return
    allocate(output(n/2))
    do i = 1, n/2
      output(i) = input(2*i-1) + input(2*i)
    end do
    status = SKL_OK
  end subroutine

  pure subroutine skl_normalize(input, output, status)
    real(real64), intent(in) :: input(:)
    real(real64), allocatable, intent(out) :: output(:)
    integer(int32), intent(out) :: status
    real(real64) :: nrm
    status = SKL_ERR_ZERO
    nrm = sqrt(sum(input*input))
    if (nrm <= tiny(nrm)) return
    allocate(output(size(input)))
    output = input / nrm
    status = SKL_OK
  end subroutine

  pure subroutine skl_identity(input, output, status)
    real(real64), intent(in) :: input(:)
    real(real64), allocatable, intent(out) :: output(:)
    integer(int32), intent(out) :: status
    allocate(output(size(input)))
    output = input
    status = SKL_OK
  end subroutine

  subroutine skl_pipeline_add_norm(input, output, status)
    real(real64), intent(in) :: input(:)
    real(real64), allocatable, intent(out) :: output(:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: tmp(:)
    call skl_add(input, tmp, status)
    if (status /= SKL_OK) return
    call skl_normalize(tmp, output, status)
  end subroutine

end module skl_production
