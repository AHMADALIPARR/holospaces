module skl_types
  use iso_fortran_env, only: real64
  implicit none
  private
  integer, parameter, public :: SKL_OK=0, SKL_ERR_IO=10, SKL_ERR_LEX=20, &
       SKL_ERR_PARSE=30, SKL_ERR_SEMANTIC=40, SKL_ERR_RESOLVE=50, SKL_ERR_EXEC=60
  integer, parameter, public :: TOK_EOF=0, TOK_IDENT=1, TOK_NUMBER=2, &
       TOK_STRING=3, TOK_SYMBOL=4, TOK_NEWLINE=5
  type, public :: token_t
    integer :: kind=TOK_EOF
    character(:), allocatable :: text
    integer :: line=1, column=1
  end type
  type, public :: token_stream_t
    type(token_t), allocatable :: items(:)
    integer :: count=0
  end type
  type, public :: functor_decl_t
    character(:), allocatable :: name, input_type, output_type, operation
    character(:), allocatable :: requires, ensures
    integer :: line=1
  end type
  type, public :: pipeline_step_t
    character(:), allocatable :: functor_name
  end type
  type, public :: pipeline_decl_t
    character(:), allocatable :: name
    type(pipeline_step_t), allocatable :: steps(:)
    integer :: line=1
  end type
  type, public :: module_ast_t
    character(:), allocatable :: name
    type(functor_decl_t), allocatable :: functors(:)
    type(pipeline_decl_t), allocatable :: pipelines(:)
  end type
  public :: append_token, append_functor, append_pipeline, append_step
contains
  subroutine append_token(stream, item)
    type(token_stream_t), intent(inout) :: stream
    type(token_t), intent(in) :: item
    type(token_t), allocatable :: tmp(:)
    integer :: n
    n=stream%count
    allocate(tmp(n+1))
    if (n>0) tmp(:n)=stream%items
    tmp(n+1)=item
    call move_alloc(tmp,stream%items)
    stream%count=n+1
  end subroutine
  subroutine append_functor(ast, item)
    type(module_ast_t), intent(inout) :: ast
    type(functor_decl_t), intent(in) :: item
    type(functor_decl_t), allocatable :: tmp(:)
    integer :: n
    n=0
    if (allocated(ast%functors)) n=size(ast%functors)
    allocate(tmp(n+1))
    if (n>0) tmp(:n)=ast%functors
    tmp(n+1)=item
    call move_alloc(tmp,ast%functors)
  end subroutine
  subroutine append_pipeline(ast, item)
    type(module_ast_t), intent(inout) :: ast
    type(pipeline_decl_t), intent(in) :: item
    type(pipeline_decl_t), allocatable :: tmp(:)
    integer :: n
    n=0
    if (allocated(ast%pipelines)) n=size(ast%pipelines)
    allocate(tmp(n+1))
    if (n>0) tmp(:n)=ast%pipelines
    tmp(n+1)=item
    call move_alloc(tmp,ast%pipelines)
  end subroutine
  subroutine append_step(pipeline, name)
    type(pipeline_decl_t), intent(inout) :: pipeline
    character(*), intent(in) :: name
    type(pipeline_step_t), allocatable :: tmp(:)
    integer :: n
    n=0
    if (allocated(pipeline%steps)) n=size(pipeline%steps)
    allocate(tmp(n+1))
    if (n>0) tmp(:n)=pipeline%steps
    tmp(n+1)%functor_name=trim(name)
    call move_alloc(tmp,pipeline%steps)
  end subroutine
end module skl_types
